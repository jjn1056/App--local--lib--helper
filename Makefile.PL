#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use inc::Module::Install;

all_from 'lib/App/local/lib/helper.pm';
repository 'git://github.com/jjn1056/App--local--lib--helper.git';

requires 'File::Spec';
requires 'local::lib';

build_requires 'Getopt::Long';
build_requires 'Config';
build_requires 'Test::More' => '0.94';

my $local_lib_helper_script = File::Spec->catdir('script','local-lib-helper');
postamble <<"EOP";
install :: install_local_lib_helper

install_local_lib_helper :
\t\$(PERL) $local_lib_helper_script @ARGV

EOP

install_script glob('script/*.pl');
auto_install;
WriteAll;

