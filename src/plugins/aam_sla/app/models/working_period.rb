
class WorkingPeriod < ActiveRecord::Base
  validates :day, :start_time, :end_time, :time_zone, :presence => true

  def days
    [l(:monday), l(:tuesday), l(:wednesday), l(:thursday), l(:friday), l(:saturday), l(:sunday)]
  end

  def day_list
    days[self.day] unless self.day.nil?
  end

  def day_list=(day_str)
    self.day = days.index(day_str)
  end

  def start_time_string
    format_time_no_time_zone_change(self.start_time) unless self.start_time.nil?
  end

  def start_time_string=(start_time_str)
    self.start_time = Time.parse(start_time_str)
  rescue ArgumentError
    @start_time_invalid = true
  end

  def end_time_string
    format_time_no_time_zone_change(self.end_time) unless self.end_time.nil?
  end

  def end_time_string=(end_time_str)
    self.end_time = Time.parse(end_time_str)
  rescue ArgumentError
    @end_time_invalid = true
  end

  def validate
    errors.add(:start_time, "is invalid") if @start_time_invalid
    errors.add(:end_time, "is invalid") if @end_time_invalid
  end

  def time_zone_string
    "(GMT" + ActiveSupport::TimeZone[self.time_zone].now.strftime("%:z") + ") " + ActiveSupport::TimeZone[self.time_zone].name
  end

  def adjust_for_current_time_zone(user_time_zone_offset)
    # Get difference between current user's time zone and working periods time zone
    current_time_zone_offset = user_time_zone_offset - get_time_zone_offset
    adjusted_start_time = self.start_time + current_time_zone_offset.seconds
    adjusted_end_time = self.end_time + current_time_zone_offset.seconds
    
    prev_day = (self.day == 0) ? 6 : self.day - 1
    next_day = (self.day == 6) ? 0 : self.day + 1
    if(adjusted_start_time.wday != adjusted_end_time.wday && # Crosses boundary, two WorkingPeriods needed
      !(adjusted_end_time.hour == 0 && adjusted_end_time.min == 0)) # Check to make sure it does not end on midnight
      if(adjusted_start_time.wday != self.start_time.wday) # Crosses boundary to previous day
        return [WorkingPeriod.new({:day => prev_day, :start_time => adjusted_start_time,
                                   :end_time => Time.parse('24:00'), :time_zone => self.time_zone}),
                WorkingPeriod.new({:day => self.day, :start_time => Time.parse('00:00'),
                                   :end_time => adjusted_end_time, :time_zone => self.time_zone})]
      elsif(adjusted_end_time.wday != self.end_time.wday) # Crosses boundary to next day
        return [WorkingPeriod.new({:day => self.day, :start_time => adjusted_start_time,
                                   :end_time => Time.parse('24:00'), :time_zone => self.time_zone}),
                WorkingPeriod.new({:day => next_day, :start_time => Time.parse('00:00'),
                                   :end_time => adjusted_end_time, :time_zone => self.time_zone})]
      end
    else
      if((adjusted_start_time.wday == self.start_time.wday - 1) ||
         (adjusted_start_time.wday == self.start_time.wday + 6)) # Moved entirely to previous day
        return [WorkingPeriod.new({:day => prev_day, :start_time => adjusted_start_time,
                                   :end_time => adjusted_end_time, :time_zone => self.time_zone})]
      elsif((adjusted_start_time.wday == self.start_time.wday + 1) ||
            (adjusted_start_time.wday == self.start_time.wday - 6)) # Moved entirely to next day
        return [WorkingPeriod.new({:day => next_day, :start_time => adjusted_start_time,
                                   :end_time => adjusted_end_time, :time_zone => self.time_zone})]
      else # Still entirely on same day
        return [WorkingPeriod.new({:day => self.day, :start_time => adjusted_start_time,
                                   :end_time => adjusted_end_time, :time_zone => self.time_zone})]
      end
    end
  end

  def specific_working_period(start_date, num_weeks)
    start_day = ((start_date.wday - 1) % 7) # Get weekday starting from Monday
    day_diff = (self.day - start_day) % 7 # Get day difference between working period and issue start date
    total_days = day_diff + num_weeks * 7
    new_start_time = specific_time(start_date, total_days, self.start_time)
    new_end_time = specific_time(start_date, total_days, self.end_time)
    WorkingPeriod.new({:day => self.day, :start_time => new_start_time, :end_time => new_end_time, :time_zone => self.time_zone})
  end

  def set_start_time(time)
    self.start_time = time
  end

  def duration
    self.end_time - self.start_time # returns in seconds
  end

  def to_s
    day.to_s + ": " + start_time.to_s + "-" + end_time.to_s
  end

  private

  def get_time_zone_offset
    ActiveSupport::TimeZone[self.time_zone].blank? ? 0 : ActiveSupport::TimeZone[self.time_zone].now.utc_offset
  end

  def specific_time(start_date, num_days, time_of_day)
    new_time = start_date + num_days * 86400 # Get correct date
    new_time.change({:hour => time_of_day.hour, :min => time_of_day.min, :sec => time_of_day.sec}) # Get correct time
  end

  def format_time_no_time_zone_change(time)
      options = {}
      options[:format] = (Setting.time_format.blank? ? :time : Setting.time_format)
      options[:locale] = User.current.language unless User.current.language.blank?
      time = time.to_time if time.is_a?(String)
      ::I18n.l(time, options)
  end
end