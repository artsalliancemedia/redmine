Redmine::Plugin.register :aam_sla do
  name 'AAM SLA plugin'
  author 'Arts Alliance Media'
  description 'Assign a Service Level Agreement, (i.e. an expected due date) to issues per priority level.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'
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

  unless IssueQuery.included_modules.include?(IssueQueryPatch)
    IssueQuery.send(:include, IssueQueryPatch)
  end
end