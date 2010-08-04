#!/usr/bin/env perl

use strict;
use warnings;
use inc::Module::Install;

all_from 'lib/App/local/lib/helper.pm';

requires 'File::Spec';
requires 'Getopt::Long';
requires 'Pod::Usage';
requires 'Config';

build_requires 'Test::More' => '0.94';

install_script glob('script/*.pl');
auto_install;
WriteAll;
