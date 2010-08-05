#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long ();
use Config;
use inc::Module::Install;

all_from 'lib/App/local/lib/helper.pm';
repository 'git://github.com/jjn1056/App--local--lib--helper.git';

requires 'File::Spec';
requires 'local::lib';

build_requires 'Getopt::Long';
build_requires 'Config';
build_requires 'Test::More' => '0.94';

auto_install;
WriteAll;

## If we are running under local::lib, then install a helper
if(
    @ARGV ||
    ($ENV{PERL_MM_OPT} and 
    ($ENV{MODULEBUILDRC} or $ENV{PERL_MB_OPT}))
) {
    require 'lib/App/local/lib/helper.pm';

    my $help = 0;
    my $which_perl = $ENV{LOCALLIB_HELPER_WHICH_PERL} || $Config{perlpath};
    my $target = $ENV{LOCALLIB_HELPER_TARGET} || undef;
    my $helper_name = $ENV{LOCALLIB_HELPER_HELPER_NAME} || 'localenv';
    my $helper_permissions = $ENV{LOCALLIB_HELPER_HELPER_PERMISSIONS} || '0755';

    my $result = Getopt::Long::GetOptions(
        'h|help' => \$help,
        'p|which_perl=s' => \$which_perl,
        't|target=s' => \$target,
        'n|helper_name=s' => \$helper_name,
        'p|helper_permissions=s' => \$helper_permissions,
    );

    if($help || !$result) {
        print <<'END';
Usage: perl Makefile.PL %OPTIONS

Options:
  -h,--help                 This help message
  -p,--which_perl           The Perl binary we are building the helper for (default: $^X)
  -t,--target               The local::lib we are building the helper for (default is current)
  -n,--helper_name          Name of the helper script (default: localenv)
  -p,--helper_permissions   Permissions given to the helper script (default 775)

Type `perldoc App::local::lib::helper` or `perldoc App::local::lib::helper::rationale`
for more details.

END
    } else {
        App::local::lib::helper->run(
            which_perl => $which_perl,
            target => $target,
            helper_name => $helper_name,
            helper_permissions => $helper_permissions,
        );
    }
}
