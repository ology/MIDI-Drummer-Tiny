#/bin/sh

# It is assumed that we are under the distribution/site directory

rm -rf ../../music-duration-partition-tutorial/assets/
rm -rf ../../music-duration-partition-tutorial/tutorial/

make clean
make all
mv -f docs/* ../../music-duration-partition-tutorial/
