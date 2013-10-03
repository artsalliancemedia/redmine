module CleanupHooks
  class CleanHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'issues/cleanup_form_hook'
    render_on :view_issues_show_description_bottom, :partial => 'issues/cleanup_show_hook'
    render_on :view_layouts_base_html_head, :partial => 'layouts/cleanup_menu_globalise_hook'
  end
end
