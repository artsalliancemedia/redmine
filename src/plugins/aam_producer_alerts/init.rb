Redmine::Plugin.register :aam_producer_alerts do
  name 'Producer alerts-to-tickets plugin'
  author 'Arts Alliance Media'
  description 'Polls Producer for new alerts, and creates stub tickets for any new ones'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'
  
  default_settings = {
    'producer_alerts_url' => 'http://localhost:8080/circuit_core/lifeguard/alerts/',
    'username' => 'admin',
    'password' => 'admin'
  }
  settings(:default => default_settings, :partial => 'settings/aam_producer_alerts_settings')

end