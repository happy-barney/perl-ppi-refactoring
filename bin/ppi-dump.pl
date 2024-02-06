#!/usr/bin/env perl

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use PPIx::Augment;
use PPI::Dumper;

my $source = shift;

my $document = PPIx::Augment->augment (-e $source ? $source : \ $source);

PPI::Dumper->new ($document)->print;
