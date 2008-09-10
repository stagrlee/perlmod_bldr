#!/usr/bin/env perl

# turn on Perl's safety features
use strict;
use warnings;
use CPANPLUS::Backend;
use CPANPLUS::Configure;
use CPANPLUS::Module;
use Config;

# create a new CPANPLUS object
my $cb = CPANPLUS::Backend->new();

# This gets cpanplus from running around on the net looking for stuff...
my $conf = $cb->configure_object;
$conf->set_conf(
    hosts => [ {
        'scheme' => 'file',
        'path' => "$Config{'prefix'}/share/perlmod_core/cpan"
    } ]);

# sort out what's installed by release tarball
my @installed = sort { $a->package cmp $b->package } $cb->installed();

# check we got that data back okay
unless (@installed)
{
  die "Can't get list of installed modules";
}

foreach my $module (@installed)
{
  print($module->package, "\t", $module->name, "\t",
    $module->package_version, 
    $module->package_is_perl_core ? "\tcore\n" : "\n");
}
