require_dependency 'issues_controller'

module IssuesControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)

    IssuesController.class_eval do
      before_filter :find_issue, :only => [:show, :edit, :update, :toggle_pause]
      before_filter :authorize, :except => [:index]
    end
  end

  module InstanceMethods
    def toggle_pause
      message = @issue.toggle_pause

      respond_to do |format|
        flash[:success] = message
        format.html { redirect_to issue_path(@issue) }
        format.js
      end
    end
  end
end