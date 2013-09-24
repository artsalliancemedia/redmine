module ProducerFields
  class FieldsHooks < Redmine::Hook::ViewListener
    render_on :view_issues_form_details_top, :partial => 'edit_fields_hook', :handlers => [:erb], :formats => [:html]
    render_on :view_issues_show_details_bottom, :partial => 'show_fields_hook', :handlers => [:erb], :formats => [:html]

    def helper_issues_show_detail_after_setting(context = { })
      if context[:detail].prop_key == 'cinema_id'
        d = Cinema.find_by_id(context[:detail].value)
        context[:detail].value = d.name unless d.nil? || d.name.nil?

        d = Cinema.find_by_id(context[:detail].old_value)
        context[:detail].old_value = d.name unless d.nil? || d.name.nil?
      elsif context[:detail].prop_key == 'screen_id'
        d = Screen.find_by_id(context[:detail].value)
        context[:detail].value = d.identifier unless d.nil? || d.identifier.nil?

        d = Screen.find_by_id(context[:detail].old_value)
        context[:detail].old_value = d.identifier unless d.nil? || d.identifier.nil?
      elsif context[:detail].prop_key == 'device_id'
        d = Device.find_by_id(context[:detail].value)
        context[:detail].value = l(d.category) unless d.nil? || d.category.nil?

        d = Device.find_by_id(context[:detail].old_value)
        context[:detail].old_value = l(d.category) unless d.nil? || d.category.nil?
      end
      ''
    end
  end
end
