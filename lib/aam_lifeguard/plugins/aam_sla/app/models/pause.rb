class Pause < ActiveRecord::Base
	validates :issue_id, :start_date, :presence => true
	belongs_to :issue

  def start_date_string
    date_to_s(self.start_date)
  end

  def end_date_string
    self.end_date == nil ? l(:still_paused) : date_to_s(self.end_date)
  end

  def date_to_s(date)
    time_zone = (User.current.time_zone.blank? ? Time.zone : User.current.time_zone)
    date.in_time_zone(time_zone).strftime('%T %D')
  end
  
	def active?
		# Returns true if the issue is currently paused
		self.end_date.blank? || self.end_date > DateTime.now.utc
	end

	def stop
		# Set the end_date of the pause
		self.end_date = DateTime.now.utc
    self.save
	end
end