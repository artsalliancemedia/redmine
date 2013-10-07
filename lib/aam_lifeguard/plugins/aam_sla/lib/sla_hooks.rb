module SlaHooks
  class SlaHooks < Redmine::Hook::ViewListener
    render_on :view_layouts_base_html_head, :partial => 'layouts/css_issues_show_hook'
  end
end
