require 'redmine'

ActionDispatch::Callbacks.to_prepare do
	require 'aam_knowledgebase'
end


Redmine::Plugin.register :aam_knowledgebase do
  name 'Knowledgebase'
  author 'Arts Alliance Media'
  description "Repurposes forum into a custom knowledgebase. Based on 'Redmine Q&A plugin' by RedmineCRM"
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'

  requires_redmine :version_or_higher => '2.1.2'
  
  settings :default => {
    :notice_message => ''
  }, :partial => 'settings/questions'

  permission :view_questions, { 
    :questions => [:index, :autocomplete_for_topic, :topics]
  }

  delete_menu_item(:top_menu, :help)
	
	#Allow extension of the 'message' model. Without this, the controller will reject this plugin's custom fields when saving/creating a message
	Message.safe_attributes 'model', 'manufacturer', 'software_version', 'firmware_version', 'issue_ids'
	Issue.safe_attributes 'message_ids' 
	
  menu :top_menu, :questions, {:controller => 'questions', :action => 'index'}, 
    :last => true,
    :caption => :label_questions, 
    :if => Proc.new {User.current.allowed_to?({:controller => 'questions', :action => 'index'}, nil, {:global => true})}    

  Redmine::AccessControl.map do |map|
    map.project_module :boards do |map|
      map.permission :view_questions, {:questions => [:autocomplete_for_topic, :topics]}
      map.permission :vote_messages, {:questions => [:vote]}
      map.permission :convert_issues, {:questions => [:convert_issue]}
      map.permission :edit_messages_tags, {}
    end
  end    
end

# Patches to the Redmine core.
Rails.configuration.to_prepare do
	Issue.send(:include, KbIssuePatch) unless Issue.included_modules.include? KbIssuePatch
	Message.send(:include, KbMessagePatch) unless Message.included_modules.include? KbMessagePatch
end
