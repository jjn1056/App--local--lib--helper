#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use inc::Module::Install;

all_from 'lib/App/local/lib/helper.pm';
repository 'git://github.com/jjn1056/App--local--lib--helper.git';

requires 'File::Spec';
requires 'Getopt::Long';
requires 'Pod::Usage';
requires 'Config';

build_requires 'Test::More' => '0.94';

install_script glob('script/*.pl');
auto_install;
WriteAll;

my $running_under_local_lib = 0;

if(
    @ARGV || 
    $ENV{LOCAL_LIB_HELPER_BOOTSTRAP} ||
    ($ENV{PERL_MM_OPT} and 
      ($ENV{MODULEBUILDRC} or $ENV{PERL_MB_OPT}))
) {
    my @args = grep {!m/--bootstrap/} @ARGV;
    system($^X, File::Spec->catdir('script', 'build_local_lib_helper.pl'), @args);
}
