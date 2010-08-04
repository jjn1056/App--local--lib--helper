#!/usr/bin/env perl

use strict;
use warnings;
use Getopt::Long;
use Pod::Usage;
use Config;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use App::local::lib::helper;

my $help = 0;
my $which_perl = $ENV{LOCALLIB_HELPER_WHICH_PERL} || $Config{perlpath};
my $target = $ENV{LOCALLIB_HELPER_TARGET} || undef;
my $helper_name = $ENV{LOCALLIB_HELPER_HELPER_NAME} || 'localenv';
my $helper_permissions = $ENV{LOCALLIB_HELPER_HELPER_PERMISSIONS} || '0755';

my $result = GetOptions(
    'h|help' => \$help,
    'p|which_perl=s' => \$which_perl,
    't|target=s' => \$target,
    'n|helper_name=s' => \$helper_name,
    'p|helper_permissions=s' => \$helper_permissions,
) or die pod2usage;
pod2usage(1) if $help;

if($help || !$result) {
    pod2usage(1);
} else {
    App::local::lib::helper->run(
        which_perl => $which_perl,
        target => $target,
        helper_name => $helper_name,
        helper_permissions => $helper_permissions,
    );
}
