class WorkingPeriod < ActiveRecord::Base
  validates :day, :start_time, :end_time, :time_zone, :presence => true

  def days
    ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday']
  end
  
  def day_string
    days[self.day]
  end

  def day_integer(day_str)
    days.index(day_str)
  end

  def day_list
  end

  def day_list=(day_str)
    self.day = days.index(day_str)
  end

  def start_time_string_new
  end

  def start_time_string_new=(start_time_str)
    self.start_time = Time.parse(start_time_str).strftime("%H:%M")
  rescue ArgumentError
    @start_time_invalid = true
  end

  def end_time_string_new
  end

  def end_time_string_new=(end_time_str)
    self.end_time = Time.parse(end_time_str).strftime("%H:%M")
  rescue ArgumentError
    @end_time_invalid = true
  end

  def validate
    errors.add(:start_time, "is invalid") if @start_time_invalid
    errors.add(:end_time, "is invalid") if @end_time_invalid
  end

  def start_time_string
    self.start_time.strftime("%I:%M%P")
  end

  def start_time_string=()
  end

  def end_time_string
    self.end_time.strftime("%I:%M%P")
  end

  def end_time_string=()
  end

  def time_zone_string
    ActiveSupport::TimeZone[self.time_zone].to_s
  end

  def time_zone_string=()
  end

  def adjust_for_current_time_zone
    current_time_zone_offset = get_current_time_zone_offset
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

  private

  def get_current_time_zone_offset
    self_time_zone_offset = ActiveSupport::TimeZone[self.time_zone].blank? ? 0 : ActiveSupport::TimeZone[self.time_zone].utc_offset
    if User.current.time_zone.blank?
      Time.zone.utc_offset - self_time_zone_offset
    else
      User.current.time_zone.utc_offset - self_time_zone_offset
    end
  end
end