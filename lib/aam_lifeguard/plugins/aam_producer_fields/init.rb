require "redmine"

require_dependency 'producer_fields_hooks'

Redmine::Plugin.register :aam_producer_fields do
  name 'Producer Fields plugin'
  author 'Arts Alliance Media'
  # Adapted from the extended_fields plugin.
  description 'Populates data for the "Cinema", "Screen" and "Device" custom fields on Redmine issue tickets.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'
  
  default_settings = {
    'producer_url' => 'https://aam-uat-producer-1/circuit_core/',
    'username' => 'admin',
    'password' => 'admin'
  }
  settings(:default => default_settings, :partial => 'settings/producer_fields_settings')

  Issue.safe_attributes 'cinema_id', 'screen_id', 'device_id'
  Issue.belongs_to :cinema
  Issue.belongs_to :screen
  Issue.belongs_to :device

  menu :admin_menu, :circuit_groups, { :controller => 'circuit_groups', :action => 'index' }, :caption => :circuit_group_plural, :after => :activity, :param => :project_id
  menu :admin_menu, :cinemas, { :controller => 'cinemas', :action => 'index' }, :caption => :cinema_plural, :after => :activity, :param => :project_id
  menu :admin_menu, :screens, { :controller => 'screens', :action => 'index' }, :caption => :screen_plural, :after => :activity, :param => :project_id
  menu :admin_menu, :devices, { :controller => 'devices', :action => 'index' }, :caption => :device_plural, :after => :activity, :param => :project_id
end

Rails.configuration.to_prepare do
  unless IssueQuery.included_modules.include?(ProducerIssueQueryPatch)
      IssueQuery.send(:include, ProducerIssueQueryPatch)
  end
end