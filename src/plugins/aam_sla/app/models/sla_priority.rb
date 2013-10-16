class SlaPriority < ActiveRecord::Base

  belongs_to :enumeration
  validates_presence_of :seconds
	
	after_commit :update_issue_due_dates
	
	def update_issue_due_dates
		Issue.where('closed_on IS NULL AND NOT is_paused AND priority_id = ?', self.issue_priority_id).each do |issue|
			issue.save_due_date
		end
		Issue.notify_mass_due_dates_change
	end

  def common_identifier
    "#{seconds}"
  end
  
  def to_s
    seconds
  end

end