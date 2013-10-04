module SlaHooks
  class SlaHooks < Redmine::Hook::ViewListener
    render_on :view_issues_index_bottom, :partial => 'issues/css_issues_show_hook'
  end
end
