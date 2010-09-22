#!/usr/bin/env perl

use strict;
use warnings;
use File::Spec;
use inc::Module::Install 1.00;

use Module::Install::Repository 0.06;
use Module::Install::AutoManifest 0.003;
use Module::Install::ReadmeMarkdownFromPod 0.003;
use Module::Install::Homepage 0.01;
use Module::Install::AutoLicense 0.08;

all_from 'lib/App/local/lib/helper.pm';

requires 'File::Spec';
requires 'local::lib';

test_requires 'Getopt::Long';
test_requires 'Config';
test_requires 'Test::More' => '0.94';

my $local_lib_helper_script = File::Spec->catdir('script','local-lib-helper');
postamble <<"EOP";
install :: install_local_lib_helper

install_local_lib_helper :
\t\$(PERL) $local_lib_helper_script @ARGV

EOP

install_script glob('script/local-lib-helper');
readme_markdown_from_pod;
auto_set_repository;
auto_set_homepage;
auto_manifest;
auto_license;
auto_install;

WriteAll;

