# Copyright (C) 2008, Lee Thompson
# Basic MIT license

AC_INIT([perlmod_core],
        [0.4.2],
        [Lee Thompson bm55b@yahoo.com])
AC_COPYRIGHT([Copyright (C) 2008, Lee Thompson])
AC_CONFIG_AUX_DIR(config)
AC_PREFIX_DEFAULT([/usr/local])
AM_INIT_AUTOMAKE()

dnl PERL_HOME
AC_ARG_WITH([perl],
  AC_HELP_STRING([--with-perl@<:@=ARG@:>@],
    [The perl install location @<:@default=PREFIX@:>@]),
  [],
  [if test "x$prefix" = xNONE; then
     with_perl=$ac_default_prefix
   else
     with_perl=${prefix}
   fi])
PERL_HOME=$with_perl
AC_SUBST(PERL_HOME)

dnl GMP_HOME
dnl most linux distros include gmp, MacIntosh does not
AC_ARG_WITH([gmp],
  AC_HELP_STRING([--with-gmp@<:@=ARG@:>@],
    [The gmp big number library installation location @<:@default=/usr@:>@]),
  [],
  [with_gmp="/usr"])
GMP_HOME=$with_gmp
SAVELIBS="${LIBS}"
LIBS="-L${with_gmp}/lib ${LIBS}"
AC_CHECK_LIB([gmp], [__gmpz_init], [], 
  AC_MSG_FAILURE([--with-gmp test for libgmp failed]))
LIBS="${SAVELIBS}"
AC_SUBST(GMP_HOME)

AC_CONFIG_FILES([
   Makefile
   get_cpan_modules.pl
   querymods_cpanp.pl
   querymods_fs.pl
   Math-GMP-2.05.patch
])

AC_OUTPUT()
