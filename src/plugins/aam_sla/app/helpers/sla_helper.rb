module SlaHelper
  def get_user_time_zone_offset
    User.current.time_zone.blank? ? Time.zone.now.utc_offset : User.current.time_zone.now.utc_offset
  end

  def update_issue_due_dates
    open_status_ids = []
    IssueStatus.where('is_closed' => false).each do |status|
      open_status_ids.push(status.id)
    end
    Issue.find_all_by_status_id(open_status_ids).each do |issue|
      issue.save_due_date
    end
  end
end