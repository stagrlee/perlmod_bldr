#!/bin/sh
# Clean out the package of all machine made files
rm -rf autom4te.cache aclocal.m4 config cpanplus DESTDIR get_cpan_STDIN.txt \
  Makefile Makefile.in configure *.pl

# Now recreate those machine made files and collect the CPAN tarballs
autoreconf -i


perl_path=$(which perl | sed -e 's,/bin/perl,,')
echo "Using perl in path ${perl_path}"
machine=$(uname -s)
# gmp is included with most linux distros, but not on MacIntosh
if [[ "${machine}" = "Darwin" ]]; then
  echo "Using machine ${machine}"
  ./configure --prefix=${perl_path} --with-gmp=${perl_path} \
    --with-perl=${perl_path} || exit 1;
else
  ./configure --prefix=${perl_path} --with-perl=${perl_path} || exit 1;
fi
# package generated and man made stuff into a tarball
make dist
