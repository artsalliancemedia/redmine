SETTINGS_PATH="/home/redmine"
APP_PATH="/home/redmine/aam_lifeguard-redmine"

cd $APP_PATH
bundle install --deployment --without rmagick

rake generate_secret_token
rake db:migrate
rake redmine:plugins:migrate