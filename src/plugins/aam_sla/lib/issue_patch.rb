require_dependency 'issue'

module IssuePatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      after_save :save_due_date, :check_for_reopen
      alias_method_chain :create_journal, :no_due_date
      alias_method_chain :css_classes, :aam_css
      has_many :pauses
    end
  end

  module InstanceMethods
    def save_due_date
      utc_working_periods = get_all_utc_working_periods
      if priority.nil? ||
         priority.sla_priority.nil? ||
         (paused? && !in_breach?) ||
         utc_working_periods.blank?
        update_column(:due_date, nil)
        update_column(:near_breach_date, nil)
        return
      end
      
      start_day = ((start_date.wday - 1) % 7) # Get weekday starting from Monday
      days_index = start_day
      num_seconds_left = priority.sla_priority.seconds
      num_near_breach_seconds_left = priority.sla_priority.seconds - priority.sla_priority.near_breach_seconds
      num_weeks = -1
      final_working_period = nil
      near_breach_working_period = nil
      while final_working_period == nil do
        while days_index < 7 do
          # Need to keep track of weeks to calculate future working period dates
          if days_index == start_day
            num_weeks += 1
          end
          day_working_periods = utc_working_periods.select{|wp| wp.day == days_index} # Get working periods for this day of the week
          day_working_periods.each do |wp|
            specific_wp = wp.specific_working_period(start_date, num_weeks) # Get working period for a specific date
            wp_length = get_working_period_length(specific_wp, start_date)
            if wp_length <= 0 # Check for negative working period duration to stop infinite loop hangs
              update_column(:due_date, nil)
              update_column(:near_breach_date, nil)
              return
            end
            if wp_length < num_near_breach_seconds_left
              num_near_breach_seconds_left -= wp_length
            elsif near_breach_working_period.nil?
              near_breach_working_period = specific_wp # This is the working period the issue is estimated to finish in
              num_near_breach_seconds_left += specific_wp.duration - wp_length # Need to account for pauses in final working period
            end
            if wp_length < num_seconds_left # Issue not finished yet
              num_seconds_left -= wp_length
            else
              final_working_period = specific_wp # This is the working period the issue is estimated to finish in
              num_seconds_left += specific_wp.duration - wp_length # Need to account for pauses in final working period
              break
            end
          end
          break unless final_working_period == nil
          days_index += 1
        end
        days_index = 0
      end

      temp_due_date = final_working_period.start_time + num_seconds_left
      if temp_due_date < Time.now.utc # If in breach, need to add on pauses since calculated due date
        temp_due_date = add_extra_pauses(temp_due_date)
      end
      update_column(:due_date, temp_due_date)
      update_column(:near_breach_date, near_breach_working_period.start_time + num_near_breach_seconds_left)
    end

    def in_breach?
      return false if due_date.nil?

      breach = (!closed_on.nil? and closed_on > due_date) ||
               (closed_on.nil? and DateTime.now > due_date)
      breach
    end

    def near_breach?
      return false if in_breach? or near_breach_date.nil? or !closed_on.nil?

      return DateTime.now > near_breach_date
    end
    
    def paused?
      self.is_paused
    end

    def out_of_hours?
      time_now = Time.now.utc
      current_day = ((time_now.wday - 1) % 7) # Get weekday starting from Monday
      get_all_utc_working_periods.each do |wp|
        if current_day == wp.day
          wp_today = wp.specific_working_period(time_now, 0) # Get today's working period
          if time_now >= wp_today.start_time && time_now <= wp_today.end_time # Are we currently in a working period
            return false
          end
        end
      end
      return true
    end

    def toggle_pause
      if self.paused?
        pauses.last.stop
        update_attribute(:is_paused, false)
      else
        # Make a new Pause
        pauses.push(Pause.new({:issue_id => id, :start_date => DateTime.now.utc}))
        update_attribute(:is_paused, true)
      end
      create_pauses_journal
    end

    def create_pauses_journal
      @current_pauses_journal ||= Journal.new(:journalized => self, :user => User.current)
      if self.paused?
        @current_pauses_journal.details << JournalDetail.new(:property => 'pause')
      else
        @current_pauses_journal.details << JournalDetail.new(:property => 'unpause')
      end
      @current_pauses_journal.save
    end

    # Have to monkey patch this whole method to remove due dates from journal
    def create_journal_with_no_due_date
      if @current_journal
        # attributes changes
        if @attributes_before_change
          # Added due date to removed columns
          (Issue.column_names - %w(id root_id lft rgt lock_version created_on updated_on closed_on due_date)).each {|c|
            before = @attributes_before_change[c]
            after = send(c)
            next if before == after || (before.blank? && after.blank?)
            @current_journal.details << JournalDetail.new(:property => 'attr',
                                                          :prop_key => c,
                                                          :old_value => before,
                                                          :value => after)
          }
        end
        if @custom_values_before_change
          # custom fields changes
          custom_field_values.each {|c|
            puts c
            before = @custom_values_before_change[c.custom_field_id]
            after = c.value
            next if before == after || (before.blank? && after.blank?)

            if before.is_a?(Array) || after.is_a?(Array)
              before = [before] unless before.is_a?(Array)
              after = [after] unless after.is_a?(Array)

              # values removed
              (before - after).reject(&:blank?).each do |value|
                @current_journal.details << JournalDetail.new(:property => 'cf',
                                                              :prop_key => c.custom_field_id,
                                                              :old_value => value,
                                                              :value => nil)
              end
              # values added
              (after - before).reject(&:blank?).each do |value|
                @current_journal.details << JournalDetail.new(:property => 'cf',
                                                              :prop_key => c.custom_field_id,
                                                              :old_value => nil,
                                                              :value => value)
              end
            else
              @current_journal.details << JournalDetail.new(:property => 'cf',
                                                            :prop_key => c.custom_field_id,
                                                            :old_value => before,
                                                            :value => after)
            end
          }
        end
        @current_journal.save
        # reset current journal
        init_journal @current_journal.user, @current_journal.notes
      end
    end

    def sla_status_raw
      if in_breach?
        :breach
      elsif paused?
        :paused
      elsif near_breach?
        :near_breach
      else
        :ok
      end
    end
    
    def sla_status
      sla_status_symbol = sla_status_raw
      extra_string = ''
      if sla_status_symbol == :breach && paused?
        extra_string = '/' + l(:paused)
      elsif sla_status_symbol == :paused && near_breach?
        extra_string = '/' + l(:near_breach)
      end
      l(sla_status_symbol) + extra_string
    end

    def css_classes_with_aam_css
      return "sla-" + sla_status_raw.to_s + " " + css_classes_without_aam_css
    end

    private

    def get_all_utc_working_periods
      adjusted_working_periods = []
      WorkingPeriod.all.each do |wp|
        wp.adjust_for_current_time_zone(0).each do |adjusted_wp|
          adjusted_working_periods.push(adjusted_wp)
        end
      end
      adjusted_working_periods.sort_by{|wp| [wp.day, wp.start_time.hour, wp.start_time.min]}
    end

    def get_working_period_length(working_period, start_date)
      wp_length = 0
      if working_period.start_time > Time.now # No pauses possible
        wp_length = working_period.duration
      elsif working_period.start_time < start_date && start_date < working_period.end_time # Issue started during current working period
        working_period.set_start_time(start_date)
        wp_length = true_working_period_length(working_period)
      elsif start_date > working_period.end_time # Issue started after current working period
        wp_length = 0
      else # Need to take pauses into account
        wp_length = true_working_period_length(working_period)
      end
      wp_length
    end

    def true_working_period_length(working_period) # Remove paused time
      wp_length = working_period.duration
      pauses.each do |p|
        if p.end_date == nil # In case paused and in breach
          next
        end
        if p.start_date <= working_period.start_time && p.end_date >= working_period.end_time # Paused for whole working period
          wp_length = 0
          break
        elsif p.start_date < working_period.end_time && p.end_date >= working_period.end_time
          wp_length -= working_period.end_time - p.start_date
        elsif p.start_date <= working_period.start_time && p.end_date > working_period.start_time
          wp_length -= p.end_date - working_period.start_time
        elsif p.start_date >= working_period.start_time && p.end_date <= working_period.end_time
          wp_length -= p.end_date - p.start_date
        end
      end
      wp_length
    end

    def add_extra_pauses(current_due_date)
      final_due_date = current_due_date
      pauses.each do |p|
        if (p.start_date > current_due_date) && (p.end_date != nil)
          final_due_date += (p.end_date - p.start_date)
        end
      end
      final_due_date
    end

    def check_for_reopen # Make sure closed_on in nil if issue is open
      unless self.status.is_closed
        update_column(:closed_on, nil)
      end
    end
  end
end
