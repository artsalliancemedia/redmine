# Release Process

We package up redmine into a .tar.gz archive file, this differs from our Python process which utilises .egg files. The equivilent in Ruby are .gem files, these however are meant for libraries and are therefore not suitable for an application unfortunately.

## Initial server set-up

* I followed [this tutorial](http://tecadmin.net/how-to-install-ruby-2-0-0-on-centos-6-using-rvm) to install Ruby 2.0.0, although >= 1.9.3 and rubygems should suffice.
* `yum install libxml2-devel libxslt-devel`
* `gem install thin bundler`

**If you need postgres then run too**

* `yum install postgresql93 postgresql93-devel postgresql93-libs`
* `service postgresql-9.3 start`
* `vi /var/lib/pgsql/9.3/data/pg_hba.conf`, set localhost to trust or remember/reset the password from installation.
* `psql -U postgres -c CREATE DATABASE redmine;`

## Release Archive

This process is controlled from our jenkins box (aam-ci-1:8080), in particular the "Redmine-GemBuild" task.

1. If you need to update the gem dependencies prior to a release use the `bundle pack` command to download a copy to `/vendor/cache`. This will then be read from `bundle install` in the future.
1. Run the task, it will spit out a ".tar.gz" file at the end.

## Demo/Test Releases

1. Run `thin stop -C /home/redmine/redmine-thin.yml`
1. `SCP` or `wget` the aam_lifeguard archive onto the `demo-redmine-1` box. (I've been copying to `/home/redmine`)
1. Extract it using `tar -xf aam_lifeguard-redmine-1.0.0.tar.gz /home/redmine/aam_lifeguard-redmine`.
1. Modify any settings files contained in `/home/redmine` if needed.
1. Modify the `build.sh` file if the version number of the archive has changed.
1. Run `/home/redmine/build.sh`, this will add in symlinks for the settings files to the appropriate location in the archive folder.
1. Run `thin start -C /home/redmine/redmine-thin.yml` to get Redmine to pick up the new settings.
1. Check `demo-redmine-1:3000` to make sure it's working :)
1. Relax with a cold beverage.

### Troubleshooting

The any settings files that are modified are stored under `/home/redmine` and are sym-linked to the correct mount point in the file system by the build shell script. 

* To find out where gems are installed to run: `gem env`
* I'm using 64-bit ruby on demo-redmine-1 for now, just because it was quicker than attempting to override all the 64-bit dependencies 
* The "thin" gem is required to be added to the Redmine Gemfile before it'll actually work as the web server for it. This is done as a part of build.sh.
* Might need to run: `gem install pg -- --with-pg-lib=/usr/pgsql-9.3/lib --with-pg-config=/usr/pgsql-9.3/bin/pg_config` to get the lifeguard gem to install.

## Live Releases

1. Bump the version number in `/src/version.txt` file.
1. Tag the release: `git tag -a 1.2.3 -m "Archive 1.2.3 version of Redmine".
1. Push the tag to GitHub: `git push upstream 1.2.3`.
1. See the section entitled "Release Archive".

@todo More steps need to be defined.

## RPM Compilation

@todo
