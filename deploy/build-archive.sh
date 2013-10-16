cd ../src
cp -r ../lib/redmine/* .

# Apply patches
for f in ./core_patches/*
do
  patch -p0 < $f
done

cd .. # Back to the root directory.

# Build archive
tar -czf aam_lifeguard-redmine-`cat ./src/version.txt`.tar.gz ./src
