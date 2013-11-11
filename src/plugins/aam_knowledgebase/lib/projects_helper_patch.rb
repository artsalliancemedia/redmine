require_dependency 'projects_helper'

module ProjectsHelperPatch
  def self.included(base) # :nodoc:
    base.send(:include, InstanceMethods)

    base.class_eval do
      unloadable
      
      alias_method_chain :project_settings_tabs, :lang_change
    end

  end
  
  module InstanceMethods
    # All this just the change the language string to "Knowledge Base", stupid plugin load order.
    def project_settings_tabs_with_lang_change
      project_settings = project_settings_tabs_without_lang_change

      project_settings.select! {|ps| ps[:name] != 'boards' }
      project_settings << {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_kb_category_plural}

      project_settings
    end
  end
end