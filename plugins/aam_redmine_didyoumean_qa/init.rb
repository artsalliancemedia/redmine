require 'redmine'

Redmine::Plugin.register :aam_redmine_didyoumean_qa do
  name 'Did You Mean? QA Version'
  author 'Arts Alliance Media'
  description 'A plugin to search for knowledge base articles when opening new issues. Based on redmine_didyoumean by Alessandro Bahgat and Mattia Tommasone.'
  version '0.0.1'
  author_url 'http://artsalliancemedia.com/'

  default_settings = {
    'project_filter' => '1',
    'min_word_length' => '2',
    'limit' => '5',
    'start_search_when' => '0'
  }

  settings(:default => default_settings, :partial => 'settings/didyoumean_qa_settings')
end

ActionDispatch::Callbacks.to_prepare do
  require 'redmine_didyoumean_qa/hooks/didyoumean_qa_hooks'
  IssuesHelper.send :include, RedmineDidyoumeanQa::Patches::SearchIssuesHelperPatch
end