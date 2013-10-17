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
    format_time(date)
  end
  
	def active?
		# Returns true if the issue is currently paused
		self.end_date.blank? || self.end_date > DateTime.now.utc
	end

	def stop
		# Set the end_date of the pause
    update_attribute(:end_date, DateTime.now.utc)
	end
end