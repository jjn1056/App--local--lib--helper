#!/usr/bin/env perl

use strict;
use warnings FATAL => 'all';
use inc::Module::Install;
use File::Spec;

requires 'File::Spec';
requires 'local::lib';

test_requires 'Getopt::Long';
test_requires 'Config';
test_requires 'Test::More' => '0.94';

all_from 'lib/App/local/lib/helper.pm';
require 'maint/Makefile.PL.include'
  if $Module::Install::AUTHOR;

my $local_lib_helper_script = 
  File::Spec->catdir('script','local-lib-helper');

postamble <<"EOP";
install :: install_local_lib_helper

install_local_lib_helper :
\t\$(PERL) $local_lib_helper_script @ARGV

EOP

install_script glob('script/local-lib-helper');
WriteAll;

