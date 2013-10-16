require_dependency 'issues_controller'

module IssuesControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    IssuesController.class_eval do
      before_filter :find_issue, :only => [:show, :edit, :update, :toggle_pause]
      before_filter :authorize, :except => [:index]
			
			alias_method_chain :build_new_issue_from_params, :copy_start_date_fix
    end
  end

  module InstanceMethods
		
		def build_new_issue_from_params_with_copy_start_date_fix
			build_new_issue_from_params_without_copy_start_date_fix
			@issue.start_date = DateTime.now if Setting.default_issue_start_date_to_creation_date?
		end
		
    def toggle_pause
      @issue.toggle_pause

      respond_to do |format|
        format.html { redirect_to issue_path(@issue) }
        format.js
      end
    end
  end
end