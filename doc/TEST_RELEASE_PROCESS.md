## Release Archive

This process is controlled from our jenkins box (aam-ci-1:8080), in particular the "Redmine-ArchiveBuild" task.

1. Bump the version number in `/src/version.txt` file.
1. If you need to update the gem dependencies prior to a release use the `bundle pack` command to download a copy to `/vendor/cache`. This will then be read from `bundle install` during deployment.
1. Tag the release: `git tag -a 1.2.3 -m "Archive 1.2.3 version of Redmine".
1. Push the tag to GitHub: `git push upstream 1.2.3`.
1. Run the "Redmine-ArchiveBuild" task, it will spit out a ".tar.gz" file at the end.
1. Each ".tar.gz" file is archived alongside the build number.

## Demo/Test Releases

1. Run `cd /home/redmine/aam_lifeguard-redmine;bundle exec thin stop -C /home/redmine/redmine-thin.yml`
1. `SCP` or `wget` the aam_lifeguard archive onto the `demo-redmine-1` box. (I've been copying to `/home/redmine`)
1. Extract it using `tar -xf aam_lifeguard-redmine-1.0.0.tar.gz /home/redmine/aam_lifeguard-redmine`.
1. Run `/home/redmine/aam_lifeguard-redmine/deploy/deploy.sh`, adds in symlinks for settings files to the appropriate locations.
1. Modify any settings files contained in `/home/redmine` if needed.
1. Run `/home/redmine/aam_lifeguard-redmine/deploy/install.sh`, runs the database migrations, drags in the dependencies
1. Run `cd /home/redmine/aam_lifeguard-redmine;bundle exec thin start -C /home/redmine/redmine-thin.yml` to get Redmine to pick up the new settings.
1. Check `demo-redmine-1:3000` to make sure it's working :)
1. Relax with a cold beverage.