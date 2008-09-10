#!/usr/bin/env perl
# This script is a packaging bridge between the perl CPAN package system
# and a package system other than CPAN.  It takes a list of PERL modules
# you want and has CPAN retrieve them, and most importantly, all of those
# module's missing dependencies; and installs those into a staged installation
# directory.  Those staged files can be input into another package manager
# like debian, gentoo, RPM, etc.
#
# Thanks to the CPANPLUS team for fixing CPAN!!!
#                                 Lee Thompson 12FEB08


# Note, I am no Perl coder.  I sincerly hope someone with some Perl coding
# skill shapes this up into something better.  We should add proxy support
# so this works inside the firewall for instance.  See TODO entries
#                                 Lee Thompson 15FEB08
use strict;
use warnings;

require 5.010_000; # first version with CPANPLUS, 5.10.0

use CPANPLUS;
use CPANPLUS::Configure;
use Config;
use Getopt::Long;
use Time::HiRes;
use Cwd;
use Switch;
use File::Path;
use Env qw(LANG DESTDIR);

# TODO add proxy support
# TODO look into CPANPLUS backend "DIST" support
$LANG = ''; # recomended in cpanplus output
my $cwd = cwd();
mkpath ( "$cwd/cpanplus/custom-sources" ); # stops a warning msg

# Are we harvesting the internet or the pre-fetched and packaged tarballs?
my $net = '';
my $result = GetOptions ( "net" => \$net );

# When CPAN starts installing modules into the staged install (DESTDIR) 
# directory, the module search path will need to be extended to include
# the new modules.  This staged dir needs to get specified all over the
# place in order for installs and tests to work
my $destdir= $DESTDIR ? $DESTDIR : "$cwd/DESTDIR";
my @myINC = (
    "$destdir$Config{'archlib'}",
    "$destdir$Config{'privlib'}",
    "$destdir$Config{'sitearch'}",
    "$destdir$Config{'sitelib'}",
    "$destdir$Config{'vendorarch'}",
    "$destdir$Config{'vendorlib'}"
);
# same as myINC, but one string with "-I" separators
my $myenv = join '', map { '-I' . $_ . ' ' } @myINC;
my $myperl = "$^X $myenv";
my $mymkf  = "FULLPERL=\"$myperl\" PERL=\"$myperl\"";

# Setup a work directory for cpan and an installation target directory
# The FULLPERL overload gets the tests working as top level Perl Modules
# will be able to load their dependent modules through extending the module
# include path.  This was necessary as CPANPLUS calls "make test" in the
# shell which the make script calls back into PERL w/o the @INC setup...
# The "lib" part extends perl's INC directory after CPANPLUS runs a flush()
my $conf = CPANPLUS::Configure->new( load_configs => 0 );
# Cpan seems super fast at facebook, cpan.org is too busy
$conf->set_conf(
    hosts => ($net) ? [ {
        'scheme' => 'http',
        'path' => '/',
        'host' => 'cpan.mirror.facebook.com'
    } ] :
    [ {
        'scheme' => 'file',
        'path' => "$cwd/cpan"
    } ] ,
    prereqs => 1,
    debug => 1,
    cpantest => 0,
    allow_build_interactivity => 0,
    base => "$cwd/cpanplus",
    makemakerflags => "DESTDIR=$destdir INSTALLDIRS=vendor",
    makeflags => "$mymkf",
    buildflags => "--destdir $destdir --installdirs vendor",
    prefer_makefile => 0,
    lib => [@myINC]
);


# clear out the sudo setting, otherwide it will run sudo
$conf->set_program( sudo => undef );


# Get a CPANPLUS object
my $cb = CPANPLUS::Backend->new($conf);

# The logic invoved does not yet take into account that this package
# may already be installed.  If it is installed, CPANPLUS will skip
# fetching and installing and when you install this package, lots
# of stuff will be missing.  So we'll do some basic checks and stop
# if packages are already installed...
# TODO - Is there a way to fix this???

my @checklist = qw(HTML::Template DBI DateTime::TimeZone Template Mail::Sender Perl::Tidy);
my $mods = $cb->module_tree();
die "Failure retrieving CPANPLUS module_tree" if ( ! $mods );
# This will say > 52,000, so it must put the entire directory in there!
# print "module_tree found " . keys (%$mods) . " modules\n";
# TODO Might be easier to use $cb->installed() instead...
print "\n*** Test build box sanity ***\n\n";
my $weregonnadie = 0;
foreach my $modname ( @checklist )
{
    if ( defined $mods->{$modname} && $mods->{$modname}->installed_version )
    {
        $weregonnadie = 1;
        print "    Found $modname " . $mods->{$modname}->installed_version . "\n";
    }
}
die "\nI do not yet support building modules that are already installed..." if ( $weregonnadie );
print "*** Looks OK ***\n\n";

# Start installation
$conf->set_conf( skiptest => 1 );
if ( "$Config{ 'osname' }" eq 'darwin' )
{   # Mac::Carbon is an unfortunate dependency for Perl Template Toolkit
    # as its test phase fails and its arch specific.
    $cb->install( modules => [ qw(Mac::Carbon) ]) || die "install of Carbon failed";
}
else
{   # Go ahead and fetch it so it will build on Lee's miserable mac later
    $cb->fetch( modules => [ qw( Mac::Carbon) ]) || die "fetch of Carbon failed";
}
# IPC::Shareable doesn't test
$cb->install( modules => [ qw(IPC::Shareable Convert::IBM390 URI) ]) || die "install of IPC::Shareable failed";
$conf->set_conf( skiptest => 0 );

# Think I have the testers working, but the ordering is wonky for some reason,
# circular? missing dependencies?  DateTime depends on DateTime::TimeZone, but, 
# DateTime::TimeZone tests depend on DateTime, so circulars do exist.
$cb->install( modules => [ qw(Devel::Symdump Class::Singleton Params::Validate) ]) || die "SYMDUMP install failed";
$cb->install( modules => [ qw(LWP XML::Parser) ]) || die "install of LWP failed";
$cb->install( modules => [ qw(DateTime::TimeZone Test::Pod Test::Pod::Coverage) ]) 
    || die "install of DateTime::Timezone failed";
$cb->install( modules => [ qw(DateTime DateTime::Format::Mail) ])
    || die "install of DateTime failed";

# These guys don't do well unless you use the old MakeMaker builder
$conf->set_conf( prefer_makefile => 1 );
$cb->install( modules => [ qw(Class::ErrorHandler Test::Class Text::ASCIITable) ]) || die "install of Class::ErrorHandler failed";
$conf->set_conf( prefer_makefile => 0 );

print "*** Big List ***\n\n";
# you are all set-up, let CPAN do its thing
$cb->install(
    modules => [ qw(
        AppConfig
        Algorithm::Diff
        Attribute::Handlers
        Array::Unique
        Bit::Vector
        C::Scan
        Carp::Ensure
        Class::Factory
        Class::Loader
        Compress::Zlib
        Config::Properties::Simple
        Convert::ASCII::Armour
        Convert::EBCDIC
        Convert::PEM
        CGI::Fast
        CGI::Session
        CPAN::WAIT
        Crypt::Blowfish
        Crypt::CBC
        Crypt::DES
        Crypt::IDEA
        Data::Grove
        Data::Buffer
        Data::Flow
        Date::Calc
        Date::Format
        Date::Manip
        DBI
        Devel::Loaded
        Digest::BubbleBabble
        Digest::HMAC
        Digest::MD2
        Digest::SHA1
        FCGI 
        Getopt::Mixed
        Getopt::Long
        Graph
        HTML::Tree
        HTML::Template
        Heap
        IPC::Run
        IPC::Shareable
        Net::Daemon
        Log::Log4perl
        Math::Bezier
        Net::SNMP
        Net::Telnet
        Perl::Tidy
        RPC::PlServer
        Sort::Versions
        Spreadsheet::SimpleExcel
        Spreadsheet::Perl
        Spreadsheet::ParseExcel
        Spreadsheet::WriteExcel
        Spreadsheet::WriteExcelXML
        String::CRC32
        Sys::Mmap
        Test::Class
        Test::Differences
        Text::Diff
        Tie::EncryptedHash
        Tie::IxHash
        XML::DOM::XPath
        XML::Generator
        XML::SAX
        XML::SemanticDiff
        XML::Simple
        XML::Twig
        XML::XPath
        XML::XPathEngine
    ) ],
    perl => $myperl ) || die "install of big list failed";

# Deal with some modules that think they are "special"
# Perl template toolkit needs a extras prefix defined
$conf->set_conf( makeflags => 
    "$mymkf TT_PREFIX=$destdir/opt/etrade/p6/share/tt2extras TT_ACCEPT=1" );
$cb->install( modules => [ qw( Template ) ] ) || die "install of Template failed";
# The DBI Plugin, specifying perl worked....
# another weird thing is you can't run Template and Template::Plugin:DBI at the same time
# as sometimes Template::Plugin::DBI runs first and fails, ughh
print "\a\a\n\nding\n";
Time::HiRes::usleep(750000);
print "\a\aHit carraige return for the Template::Plugin::DBI install!!!\n";
Time::HiRes::usleep(750000);
print "\a\ading\n\n\n";
$cb->install( modules => [ qw( Template::Plugin::DBI ) ],
    perl => $myperl ) || die "install of Template::Plugin::DBI failed";
# Mail::Sender hangs on user input, ughhh
$conf->set_conf( makeflags => "$mymkf" );
# TODO pump in a carraige return here for the Mail::Sender module please.
print "\a\a\n\nding\n";
Time::HiRes::usleep(750000);
print "\a\aHit carraige return for the Mail::Sender install!!!\n";
Time::HiRes::usleep(750000);
print "\a\ading\n\n\n";
$cb->install( modules => [ qw( Mail::Sender ) ] ) || die "install of Mail::Sender failed";
print "\a\a moving along\n";


# back to normal config
$cb->install(
    modules => [ qw(
        Template::Constants
        Template::Plugin::XML
        Template::Plugin::Cycle
    ) ],
    perl => $myperl) || die "install of 2nd list failed";

# Doesn't specify DBI dependency and doesn't test
$conf->set_conf( skiptest => 1 );
$cb->install(
    modules => [ qw( DBIx::Recordset) ],
    perl => $myperl) || die "install of DBIx::Recordset failed";
$conf->set_conf( skiptest => 0 );

