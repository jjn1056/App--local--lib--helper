#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw($Bin);
use lib "$Bin/../lib";

my %opts = ();

use App::local::lib::helper;
App::local::lib::helper->run(%opts);
