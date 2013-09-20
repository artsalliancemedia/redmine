# Release Process

Gems are the Ruby equivilent of Pythons eggs and work in a similar way so this is what we'll use.

This repository only has the additional code required to transform a standard Redmine installation into a ticketing system, therefore before/whilst making the gem we must pull in all the dependencies required to make a fully fledged product. To manage this we use jenkins to perform the pre-build steps and then rubygems itself pulls in the ruby dependencies as a part of the build process.

## RPM Compilation

@todo

## Nginx Configuration

@todo