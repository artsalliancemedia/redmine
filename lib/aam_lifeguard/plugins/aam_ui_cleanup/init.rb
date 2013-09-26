require "redmine"

require_dependency 'cleanup_hooks'

Redmine::Plugin.register :aam_ui_cleanup do
  name 'UI cleanup'
  author 'Arts Alliance Media'
  description 'Removes unwanted redmine UI items and db data.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com'
end