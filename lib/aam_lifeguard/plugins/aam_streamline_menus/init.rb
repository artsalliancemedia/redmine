require 'redmine'

Redmine::Plugin.register :aam_streamline_menus do
  name 'Streamline Menus'
  author 'Arts Alliance Media'
  description 'Remove some superfluous menu items.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com/'

  delete_menu_item(:top_menu, :projects)
  delete_menu_item(:top_menu, :questions) # @todo <- Doesn't work because plugins are loaded alphabetically so cannot override redmine_questions :S
  delete_menu_item(:project_menu, :overview)
  delete_menu_item(:project_menu, :activity)
  delete_menu_item(:project_menu, :boards)

  menu :project_menu, :boards, {:controller => 'boards', :action => 'index'}, :caption => :label_questions, :after => :new_issue, :param => :project_id
end