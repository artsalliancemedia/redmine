require_dependency 'issue'

module IssuePatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    Issue.class_eval do
      before_save :sla_service
      has_many :pauses
    end
  end

  module InstanceMethods
    def due_date
      if estimated_hours.blank? || paused? || WorkingPeriod.blank? # Due date invalid
        return
      end

      utc_working_periods = get_all_utc_working_periods
      start_day = ((start_date.wday - 1) % 7) # Get weekday starting from Monday
      days_index = start_day
      num_seconds_left = estimated_hours * 3600
      num_weeks = -1
      final_working_period = nil
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
            if wp_length < num_seconds_left # Issue not finished yet
              num_seconds_left -= wp_length
            else
              final_working_period = specific_wp # This is the working period the issue is estimated to finish in
              num_seconds_left += (specific_wp.end_time - specific_wp.start_time) - wp_length # Need to account for pauses in final working period
              break
            end
          end
          break unless final_working_period == nil
          days_index += 1
        end
        days_index = 0
      end

      final_working_period.start_time + num_seconds_left
    end

    def sla_service
      return if priority.nil?

      if priority.sla_priority.nil?
        self.due_date = nil
      else
        self.due_date = start_date + priority.sla_priority.seconds
      end
    end

    def in_breach?
      return false if due_date.nil?

      breach = (!closed_on.nil? and closed_on > due_date)
      breach ||= DateTime.now > due_date
      breach
    end
    
    def paused?
      if pauses.count > 0
        pauses.last.active?
      else
        false
      end
    end

    def out_of_hours?
      time_now = Time.now
      current_day = ((time_now.wday - 1) % 7) # Get weekday starting from Monday
      get_all_utc_working_periods.each do |wp|
        if current_day == wp.day
          wp_today = wp.specific_working_period(time_now, 0) # Get today's working period
          if time_now > wp_today.start_time && time_now < wp_today.end_time # Are we currently in a working period
            return false
          end
        end
      end
      return true
    end

    def toggle_pause
      if self.paused?
        pauses.last.stop
      else
        # Make a new Pause
        pauses.push(Pause.new({:issue_id => id, :start_date => DateTime.now.utc}))
      end
    end

    def sla_status_raw
      if in_breach?
        :breach
      elsif paused?
        :paused
      else
        :ok
      end
    end
    
    def sla_status
      out_of_hours_string = out_of_hours? ? (' (' + l(:out_of_hours) + ')') : ''
      l(sla_status_raw) + out_of_hours_string
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
        wp_length = working_period.end_time - working_period.start_time
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
      wp_length = working_period.end_time - working_period.start_time
      pauses.each do |p|
        if p.start_date <= working_period.start_time && p.end_date >= working_period.end_time # Paused for whole working period
          wp_length = 0
          break
        elsif p.start_date < working_period.end_time && p.end_date >= working_period.end_time
          wp_length -= working_period.end_time - p.start_date
        elsif p.start_date <= working_period.start_time && p.end_date < working_period.end_time
          wp_length -= p.end_date - working_period.start_time
        elsif p.start_date >= working_period.start_time && p.end_date <= working_period.end_time
          wp_length -= p.end_date - p.start_date
        end
      end
      wp_length
    end
  end
end
