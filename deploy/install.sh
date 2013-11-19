SETTINGS_PATH="/home/redmine"
APP_PATH="/home/redmine/aam_lifeguard-redmine"

cd $APP_PATH
bundle install --deployment --without rmagick

RAILS_ENV=production bundle exec rake generate_secret_token
RAILS_ENV=production bundle exec rake db:migrate
RAILS_ENV=production bundle exec rake redmine:plugins:migrate