# Copyright (C) 2008, Lee Thompson
# Basic MIT license

AC_INIT([perlmod_core],
        [0.4],
        [Lee Thompson bm55b@yahoo.com])
AC_COPYRIGHT([Copyright (C) 2008, Lee Thompson])
AC_CONFIG_AUX_DIR(config)
AC_PREFIX_DEFAULT([/usr/local])
AM_INIT_AUTOMAKE()

dnl PERL_HOME
AC_ARG_WITH([perl],
  AC_HELP_STRING([--with-perl@<:@=ARG@:>@],
    [The perl install location @<:@default=/usr/local@:>@]),,
  [with_perl="/usr/local"])
PERL_HOME=$with_perl
AC_SUBST(PERL_HOME)

AC_CONFIG_FILES([
   Makefile
])

AC_OUTPUT()
