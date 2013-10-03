module CleanupHooks
  class CleanHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'cleanup_form_hook'
    render_on :view_issues_show_description_bottom, :partial => 'cleanup_show_hook'
  end
end
