require 'redmine'

require_dependency 'issue_hooks'

Redmine::Plugin.register :aam_issue_resolutions do
  name 'AAM Issue Resolutions'
  author 'Arts Alliance Media'
  description 'Adds nested resolution field to the issue model.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'

  Issue.safe_attributes 'resolution_id'
  Issue.belongs_to :resolution, :class_name => 'IssueResolution', :foreign_key => 'resolution_id'

  permission :manage_resolutions, :resolutions => [:index]
end

ActionDispatch::Callbacks.to_prepare do
  Project.send(:include, ProjectPatch) unless Project.included_modules.include?(ProjectPatch)
  IssueQuery.send(:include, IssueQueryPatch) unless IssueQuery.included_modules.include?(IssueQueryPatch)
end
