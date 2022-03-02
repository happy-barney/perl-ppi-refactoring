#!/usr/bin/env perl

use PPI;
use PPI::Dumper;

my $document = PPI::Document->new (shift);

use FindBin;
use lib "$FindBin::Bin/../lib";

use PPIx::Augment;

PPIx::Augment->augment ($document);

PPI::Dumper->new ($document)->print;

