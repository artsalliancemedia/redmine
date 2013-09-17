class IssueStatusesHook < Redmine::Hook::ViewListener
	render_on :view_issue_statuses_form, :partial => 'issue_statuses/producer_name_form_hook'
end
