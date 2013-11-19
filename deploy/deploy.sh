SETTINGS_PATH="/home/redmine"
APP_PATH="/home/redmine/aam_lifeguard-redmine"

# Copy over the files into a central location if this is a new installation, DON'T OVERWRITE!
echo n | cp -i "$APP_PATH/deploy/redmine-thin.yml.example" "$SETTINGS_PATH/redmine-thin.yml"
echo n | cp -i "$APP_PATH/config/database.yml.example" "$SETTINGS_PATH/database.yml"
echo n | cp -i "$APP_PATH/config/configuration.yml.example" "$SETTINGS_PATH/configuration.yml"
echo n | cp -i "$APP_PATH/config/additional_environment.rb.example" "$SETTINGS_PATH/additional_environment.rb"

ln -s "$SETTINGS_PATH/database.yml" "$APP_PATH/config/database.yml"
ln -s "$SETTINGS_PATH/configuration.yml" "$APP_PATH/config/configuration.yml"
ln -s "$SETTINGS_PATH/additional_environment.rb" "$APP_PATH/config/additional_environment.rb"

mkdir /var/log/aam_lifeguard-redmine
