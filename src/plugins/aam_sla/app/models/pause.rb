class Pause < ActiveRecord::Base
	validates_presence_of :issue_id, :start_date
	belongs_to :issue

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