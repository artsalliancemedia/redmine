require "redmine"
require_dependency 'sla_hooks'

Redmine::Plugin.register :aam_sla do
  name 'AAM SLA plugin'
  author 'Arts Alliance Media'
  description 'Assign a Service Level Agreement, (i.e. an expected due date) to issues per priority level.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'

  menu :admin_menu, :working_periods, { :controller => 'working_periods', :action => 'index' }, :caption => :working_period_plural

  project_module :issue_tracking do
    permission :issue_toggle_pause, :issues => :toggle_pause
  end
end

Rails.configuration.to_prepare do
  unless IssuePriority.included_modules.include?(IssuePriorityPatch)
    IssuePriority.send(:include, IssuePriorityPatch)
  end

  unless EnumerationsController.included_modules.include?(EnumerationsControllerPatch)
    EnumerationsController.send(:include, EnumerationsControllerPatch)
  end

  unless Issue.included_modules.include?(IssuePatch)
    Issue.send(:include, IssuePatch)
  end

  unless IssuesController.included_modules.include?(IssuesControllerPatch)
    IssuesController.send(:include, IssuesControllerPatch)
  end

  unless IssueQuery.included_modules.include?(IssueQueryPatch)
    IssueQuery.send(:include, IssueQueryPatch)
  end

  unless User.included_modules.include?(TzUserPatch)
    User.send(:include, TzUserPatch)
  end

  IssuesHelper.module_eval do
    alias_method :old_show_detail, :show_detail

    def show_detail(detail, no_html=false, options={})
      if detail.property == 'pause'
        l(:text_journal_paused)
      elsif detail.property == 'unpause'
        l(:text_journal_unpaused)
      else
        old_show_detail(detail, no_html, options)
      end
    end
  end
end