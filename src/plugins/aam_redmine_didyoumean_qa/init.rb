require 'redmine'

Redmine::Plugin.register :aam_redmine_didyoumean_qa do
  name 'Related issues and articles auto-suggest'
  author 'Arts Alliance Media'
  description 'Searchs for knowledge base articles and other issues when opening new issues.
		The search uses device (if selected), and subject field.
		Based on redmine_didyoumean by Alessandro Bahgat and Mattia Tommasone.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com/'
end

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_didyoumean_qa/hooks/didyoumean_qa_hooks'
end