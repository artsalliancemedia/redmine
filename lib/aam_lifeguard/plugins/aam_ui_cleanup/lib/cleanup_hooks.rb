module CleanupHooks
  class CleanHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'cleanup_hook'
  end
end
