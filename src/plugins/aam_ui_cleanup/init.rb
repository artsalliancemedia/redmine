require "redmine"

require_dependency 'cleanup_hooks'

Redmine::Plugin.register :aam_ui_cleanup do
  name 'UI cleanup'
  author 'Arts Alliance Media'
  description 'Removes unwanted redmine UI items and db data.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'

  # Delete some superfluous menus.
  delete_menu_item(:top_menu, :projects)
  delete_menu_item(:project_menu, :overview)
  delete_menu_item(:project_menu, :activity)
  delete_menu_item(:project_menu, :boards)
  delete_menu_item(:project_menu, :settings)
  delete_menu_item(:admin_menu, :ldap_authentication)
  delete_menu_item(:admin_menu, :info)
  delete_menu_item(:admin_menu, :enumerations)

  menu :admin_menu, :enumerations, { :controller => 'enumerations', :action => 'index' }, :caption => :enumeration_issue_priorities
  menu :project_menu, :boards, {:controller => 'boards', :action => 'index'}, :caption => :label_questions, :after => :new_issue, :param => :project_id
end

Rails.configuration.to_prepare do
  QueriesHelper.send(:include, QueriesHelperPatch) unless QueriesHelper.included_modules.include?(QueriesHelperPatch)
  RolesController.send(:include, RolesControllerPatch) unless RolesController.included_modules.include?(RolesControllerPatch)
  Role.send(:include, RolePatch) unless Role.included_modules.include?(RolePatch)
end