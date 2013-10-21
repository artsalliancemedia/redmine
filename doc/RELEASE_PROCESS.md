# Release Process

We package up redmine into a .tar.gz archive file, this differs from our Python process which utilises .egg files. The equivilent in Ruby are .gem files, these however are meant for libraries and are therefore not suitable for an application unfortunately.

## Initial server set-up

1. I followed [this tutorial](http://tecadmin.net/how-to-install-ruby-2-0-0-on-centos-6-using-rvm) to install Ruby 2.0.0, although >= 1.9.3 and rubygems should suffice.
1. `yum install libxml2-devel libxslt-devel`
1. `gem install thin bundler`
1. **If you need postgres then run too**
  * `yum install postgresql93 postgresql93-devel postgresql93-libs`
  * `service postgresql-9.3 start`
  * `vi /var/lib/pgsql/9.3/data/pg_hba.conf`, set localhost to trust or remember/reset the password from installation.
  * `psql -U postgres -c CREATE DATABASE redmine;`
1. Copy `config/database.yml.example` to `config/database.yml` and modify it to point at the redmine database.

## Release Archive

This process is controlled from our jenkins box (aam-ci-1:8080), in particular the "Redmine-ArchiveBuild" task.

1. First update the `version.txt` file found in the redmine repo under `src`.
1. If you need to update the gem dependencies prior to a release use the `bundle pack` command to download a copy to `/vendor/cache`. This will then be read from `bundle install` during deployment.
1. Run the "Redmine-ArchiveBuild" task, it will spit out a ".tar.gz" file at the end.
1. Each ".tar.gz" file is archived alongside the build number.

## Demo/Test Releases

1. Run `bundle exec thin stop -C /home/redmine/redmine-thin.yml`
1. `SCP` or `wget` the aam_lifeguard archive onto the `demo-redmine-1` box. (I've been copying to `/home/redmine`)
1. Extract it using `tar -xf aam_lifeguard-redmine-1.0.0.tar.gz /home/redmine/aam_lifeguard-redmine`.
1. Modify any settings files contained in `/home/redmine` if needed.
1. Modify the `build.sh` file if the version number of the archive has changed.
1. Run `/home/redmine/build.sh`, this will add in symlinks for the settings files to the appropriate location in the archive folder.
1. Run `rake db:migrate` and `rake redmine:plugins:migrate` to update the database.
1. Run `bundle exec thin start -C /home/redmine/redmine-thin.yml` to get Redmine to pick up the new settings.
1. Check `demo-redmine-1:3000` to make sure it's working :)
1. Relax with a cold beverage.

### Troubleshooting

The any settings files that are modified are stored under `/home/redmine` and are sym-linked to the correct mount point in the file system by the build shell script. 

* To find out where gems are installed to run: `gem env`
* I'm using 64-bit ruby on demo-redmine-1 for now, just because it was quicker than attempting to override all the 64-bit dependencies 
* The "thin" gem is required to be added to the Redmine Gemfile before it'll actually work as the web server for it. This is done as a part of build.sh.
* Might need to run: `gem install pg -- --with-pg-lib=/usr/pgsql-9.3/lib --with-pg-config=/usr/pgsql-9.3/bin/pg_config` to get the lifeguard gem to install.

## Live Releases

Make sure that the steps prefixed by *1st Installation* are only run the **first time** an installation occurs, NOT subsequent updates!

1. Bump the version number in `/src/version.txt` file.
1. Tag the release: `git tag -a 1.2.3 -m "Archive 1.2.3 version of Redmine".
1. Push the tag to GitHub: `git push upstream 1.2.3`.
1. See the section entitled "Release Archive".
1. *System Update:* Run `bundle exec thin stop -C deploy/redmine-thin.yml`.
1. *System Update:* Run `tar -cfz aam_lifeguard-redmine.\`date "+%Y%m%dT%H%M"\`.tar.gz aam_lifeguard-redmine/` to backup the old installation, then remove it `rm -rf aam_lifeguard-redmine/`.
1. Extract the ".tar.gz" release archive file to a place on the filesystem.
1. *1st Installation:* Copy `config/database.yml.example` to `config/database.yml` and modify it to point at the redmine database.
1. *1st Installation:* Copy `config/configuration.yml.example` to `config/configuration.yml` and modify it to set up the email configuration.
1. *1st Installation:* Copy `config/additional_environment.rb.example` to `config/additional_environment.rb` and modify it to set the logging requirements. See the "Logging" section below for help.
1. Run `bundle install --deployment --without rmagick` to install the gem dependencies that come with the archive.
1. Run `rake generate_secret_token` to create a session validation token unique to this instance.
1. Run `rake db:migrate` from the root folder of the archive. Also run `rake redmine:plugins:migrate`, after these are complete the database schema should be up to date.
1. *1st Installation:* Run `rake redmine:load_default_data` to load Redmine's default dataset and then `rake lifeguard:data_modify` to modify it for lifeguards requirements.
1. *1st Installation:* Install the cron tasks, see the "Cron Tasks" section below for more details.
1. Run `bundle exec thin start -C deploy/redmine-thin.yml` to get Redmine to pick up the new settings. Modify that file if you need to change the default deploy settings (you probably do).
1. Check `localhost:3000` to make sure it's working :)
1. Relax with a cold beverage.

### Logging

These lines are required, if you want to have redmine handle log rotation, in the `additional_environment.rb` file to successfully capture debug output.

```
config.log_level = :debug
config.logger = Logger.new('/var/log/aam_lifeguard-redmine.app.log', 5, 104857600) # Logger.new(PATH,NUM_FILES_TO_ROTATE,FILE_SIZE)
config.logger.level = 0
```

### Cron Tasks

Ensure these entries are in the cron scheduler (normally `/etc/crontab`). Change the value of `<user>` to the user you wish to run the task under.

```
0 * * * * <user> /bin/bash -l -c 'cd /path/aam_lifeguard-redmine/ && RAILS_ENV=production rake lifeguard:producer_pull >> /var/log/producer_pull.log'
0/5 * * * * <user> /bin/bash -l -c 'cd /path/aam_lifeguard-redmine/ && RAILS_ENV=production rake lifeguard:producer_push >> /var/log/producer_push.log'
0/5 * * * * <user> /bin/bash -l -c 'cd /path/aam_lifeguard-redmine/ && RAILS_ENV=production rake lifeguard:producer_alerts >> /var/log/producer_alerts.log'
```