#!/bin/sh
# Clean out the package of all machine made files
rm -rf autom4te.cache aclocal.m4 config cpanplus DESTDIR get_cpan_STDIN.txt
# Now recreate those machine made files and collect the CPAN tarballs
autoreconf -i
./configure
# package generated and man made stuff into a tarball
make dist
