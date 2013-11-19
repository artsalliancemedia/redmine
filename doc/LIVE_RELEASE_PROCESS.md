# Release Process

We package up lifeguard-redmine into a .tar.gz archive file, this differs from our Python process which utilises .egg files. The equivilent in Ruby are .gem files, these however are meant for libraries and are therefore not suitable for an application unfortunately.

## Initial server set-up

1. I followed [this tutorial](http://tecadmin.net/how-to-install-ruby-2-0-0-on-centos-6-using-rvm) to install Ruby 2.0.0, although >= 1.9.3 should suffice. *Make sure to install the `ruby-devel` packages for your version of ruby too!*
1. Install RubyGems > 2.1.x.
1. `yum install libxml2-devel libxslt-devel postgresql93-devel` - These are needed for the underlying components used by Redmine.
1. `gem install bundler`
1. Run `bundle config build.pg --with-pg-config=/usr/pgsql-9.3/bin/pg_config`. This tells bundler where to find the postgresql-devel header files for compliation of the postgres gem.
1. **If you need postgres on the box then run these commands too:**
  * `yum install postgresql93 postgresql93-libs`
  * `service postgresql-9.3 start`
  * `vi /var/lib/pgsql/9.3/data/pg_hba.conf`, set localhost to trust or remember/reset the password from installation.
  * `psql -U postgres -c CREATE DATABASE redmine;`
1. Make a `redmine` user, give it a home directory of `/home/redmine`.

## Live Releases

Make sure that the steps prefixed by *1st Installation* are only run the **first time** an installation occurs, NOT subsequent updates!

1. Log on to the box to be installed/updated, preferably as root.
1. *System Update:* Run `cd /home/redmine/aam_lifeguard-redmine;bundle exec thin stop -C /home/redmine/redmine-thin.yml`.
1. *System Update:* Run `tar -cfz /home/redmine/aam_lifeguard-redmine.\`date "+%Y%m%dT%H%M"\`.tar.gz aam_lifeguard-redmine/` to backup the old installation, then remove it `rm -rf /home/redmine/aam_lifeguard-redmine`.
1. Copy the `aam_lifeguard-redmine.tar.gz` file to the box and extract to `/home/redmine/aam_lifeguard-redmine`.
1. Execute `/home/redmine/aam_lifeguard-redmine/deploy/deploy.sh`. This copies the settings files locally to the machine and won't overwrite them on system update so settings are preserved.
1. Modify settings files, they're in `/home/redmine`.
  * `database.yml` controls the configuration details to the database (unsurprisingly).
  * `configuration.yml` controls the email configuration (it also does other things, but for us this is it).
  * `additional_environment.rb` controls the logging output, please see the "Logging" section below for further details.
  * `redmine-thin.yml` controls the thin server settings, see the "Deployment" section below for further details.
1. Execute `/home/redmine/aam_lifeguard-redmine/deploy/install.sh` this will install the dependencies and perform any database migrations.
1. *1st Installation:* Run `RAILS_ENV=production rake redmine:load_default_data` to load Redmine's default dataset.
1. *1st Installation:* Then run `RAILS_ENV=production rake lifeguard:data_modify` to modify the default data for lifeguards requirements.
1. *1st Installation:* Install the cron tasks, see the "Cron Tasks" section below for more details.
1. Run `cd /home/redmine/aam_lifeguard-redmine;bundle exec thin start -C /home/redmine/redmine-thin.yml` to get Redmine to pick up the new settings.
1. Check `localhost:7000` to make sure it's working :)
1. Relax with a cold beverage.

### Logging

These lines are required, if you want to have redmine handle log rotation, in the `additional_environment.rb` file to successfully capture debug output.

```
config.log_level = :debug
config.logger = Logger.new('/var/log/aam_lifeguard-redmine/app.log', 5, 104857600) # Logger.new(PATH,NUM_FILES_TO_ROTATE,FILE_SIZE)
config.logger.level = 0
```

### Cron Tasks

Ensure these entries are in the cron scheduler (normally `/etc/crontab`). Change the value of `<user>` to the user you wish to run the task under.

```
*/5 * * * * <user> /bin/bash -l -c 'cd /home/redmine/aam_lifeguard-redmine/ && RAILS_ENV=production bundle exec rake lifeguard:producer_pull >> /var/log/aam_lifeguard-redmine/producer_pull.log 2>&1'
*/2 * * * * <user> /bin/bash -l -c 'cd /home/redmine/aam_lifeguard-redmine/ && RAILS_ENV=production bundle exec rake lifeguard:producer_push >> /var/log/aam_lifeguard-redmine/producer_push.log 2>&1'
*/2 * * * * <user> /bin/bash -l -c 'cd /home/redmine/aam_lifeguard-redmine/ && RAILS_ENV=production bundle exec rake lifeguard:producer_alerts >> /var/log/aam_lifeguard-redmine/producer_alerts.log 2>&1'
```

### Deployment

@todo: to complete.

### Troubleshooting

The any settings files that are modified are stored under `/home/redmine` and are sym-linked to the correct mount point in the file system by the build shell script. 

* I'm using 64-bit ruby on demo-redmine-1 for now, just because it was quicker than attempting to override all the 64-bit dependencies.
* Might need to run: `gem install pg -- --with-pg-lib=/usr/pgsql-9.3/lib --with-pg-config=/usr/pgsql-9.3/bin/pg_config` to get the postgres (pg) gem to install.
