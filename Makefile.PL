#!/usr/bin/env perl

use lib 'maint/lib';
use Maker;
use File::Spec;

all_from 'lib/App/local/lib/helper.pm';

requires 'FindBin';
requires 'File::Spec';
requires 'local::lib';
requires 'Getopt::Long';
requires 'Config';

test_requires 'Test::More' => '0.94';
tests_recursive;

install_script glob('script/local-lib-helper');

my $local_lib_helper_script =
  File::Spec->catdir('script','local-lib-helper');

postamble <<"EOP";
install :: install_local_lib_helper

install_local_lib_helper :
\t\$(PERL) $local_lib_helper_script @ARGV

EOP

