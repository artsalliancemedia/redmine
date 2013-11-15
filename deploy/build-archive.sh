cd ../src
cp -r ../lib/redmine/* .
cp ./public/themes/AAM/img/favicon.ico ./public/favicon.ico

mkdir deploy
cp -r ../deploy/* ./deploy/

mkdir user_docs
cp -r ../doc/* ./user_docs

# Apply patches
for f in ./core_patches/*
do
  patch -p0 < $f
done

cd .. # Back to the root directory.

mv ./src aam_lifeguard-redmine

# Build archive
tar -czf aam_lifeguard-redmine-`cat ./aam_lifeguard-redmine/version.txt`.tar.gz ./aam_lifeguard-redmine
