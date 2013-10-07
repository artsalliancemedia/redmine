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

  menu :project_menu, :boards, {:controller => 'boards', :action => 'index'}, :caption => :label_questions, :after => :new_issue, :param => :project_id
end