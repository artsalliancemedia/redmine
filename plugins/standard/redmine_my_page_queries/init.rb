ActionDispatch::Callbacks.to_prepare do
  require 'my_page_queries'
end

Redmine::Plugin.register :redmine_my_page_queries do
  name 'MyPage custom queries'
  description 'Adds custom queries onto My Page screen'
  version '2.0.7'
  author 'Undev'
  author_url 'https://github.com/Undev'
  url 'https://github.com/Undev/redmine_my_page_queries'

  requires_redmine :version_or_higher => '2.1.0'
end
