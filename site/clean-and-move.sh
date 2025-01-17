#/bin/sh

# It is assumed that we are under the distribution/site directory

rm -rf ../../midi-drummer-tiny-tutorial/assets/
rm -rf ../../midi-drummer-tiny-tutorial/tutorial/

make clean
make all
mv -f docs/* ../../midi-drummer-tiny-tutorial/
