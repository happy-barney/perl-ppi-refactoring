
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw ( :no_end_test had_no_warnings );

use_ok q (PPIx::Augment);
use_ok q (PPIx::Augment::Utils::Exporter);

had_no_warnings;
done_testing;
