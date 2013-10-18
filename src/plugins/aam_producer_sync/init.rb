Redmine::Plugin.register :aam_producer_sync do
  name 'Producer Ticket Sync plugin'
  author 'Arts Alliance Media'
  description 'Syncs slimmed-down ticket data to Producer, as a manual Rake task.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'
  
  default_settings = {
    'producer_sync_url' => 'https://aam-uat-producer-1/circuit_core/lifeguard/tickets/',
		'username' => 'admin',
    'password' => 'admin'
  }
  settings(:default => default_settings, :partial => 'settings/aam_producer_sync_settings')

end

#Rails.configuration.to_prepare do
#  unless Issue.included_modules.include?(AamProducerSyncIssuePatch)
#    Issue.send(:include, AamProducerSyncIssuePatch)
#  end
#end
