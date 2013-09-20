# Developer Installation Process

Hopefully shouldn't take too long!

## Prerequisites

Please install:

* Ruby 2.0.x (x86)
* Ruby Gems 2.0.x
* Postgres 9.3.x (x86 or x64)
* Ruby DevTools (if on windows)

## Next Steps

Please follow these steps in order:

1. Download a copy of Redmine 2.3.x, follow the install instructions included to get a working installation.
1. Copy across the `AAM` theme to the redmine installation directory. The theme can be found found under `/public/themes/AAM`.
  * Restart the redmine web server.
  * Then login to Redmine, navigate to *Administration* then to *Settings* and finally to *Display*.
  * On the *Display* page there is an option to change over the theme to `AAM`.
  * Click around and test the installation is still working correctly before proceeding.
1. Copy across the `/patches` folder to the root of the redmine installation directory.
  * Stop the redmine webserver.
  * To apply the patch(es) correctly please run `patch -p0 -i <redmine_dir>/patches/patch_123.diff`. This will modify the code.
  * Then run the command `rake db:migrate` in the root folder. This will modify the database.
  * Start the redmine webserver.
  * Login and test the installation is still working correctly before proceeding.
1. Copy across the plugins found within `/plugins` to the `/plugins` folder in the redmine installation directory.
  * Run the command `rake redmine:plugins:migrate` to safely apply any database changes that are required.
  * Restart the redmine web server.
  * Login and test again to make sure the installation is still working.

You should now have a working installation with all the modifications, the next step is to customise the installation. Please see CUSTOMISE.md for detailed instructions.

## Troubleshooting

Nothing in here yet, I'm sure we will soon enough :)