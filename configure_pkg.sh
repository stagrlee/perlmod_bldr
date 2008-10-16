#!/bin/sh
# Clean out the package of all machine made files
rm -rf autom4te.cache aclocal.m4 config cpanplus DESTDIR get_cpan_STDIN.txt
# Now recreate those machine made files and collect the CPAN tarballs
autoreconf -i
perl_path=$(which perl | sed -e 's,/bin/perl,,')
echo "Using perl in path ${perl_path}"
./configure --prefix=${perl_path} --with-perl=${perl_path}
# package generated and man made stuff into a tarball
make dist
