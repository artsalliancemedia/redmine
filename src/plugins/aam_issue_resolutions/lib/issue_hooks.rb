module ResolutionField
  class FieldsHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_bottom, :partial => 'resolution_field_hook', :handlers => [:erb], :formats => [:html]
    render_on :view_issues_show_details_bottom, :partial => 'show_resolution_field_hook', :handlers => [:erb], :formats => [:html]

    def helper_issues_show_detail_after_setting(context = { })
      if context[:detail].prop_key == 'resolution_id'
        d = IssueResolution.find_by_id(context[:detail].value)
        context[:detail].value = d.name unless d.nil? || d.name.nil?

        d = IssueResolution.find_by_id(context[:detail].old_value)
        context[:detail].old_value = d.name unless d.nil? || d.name.nil?
      end
      ''
    end
  end
end