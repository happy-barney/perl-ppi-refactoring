
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw ( :no_end_test had_no_warnings );

use_ok $_ for qw (
	PPIx::Augment
	PPIx::Augment::Internals
	PPIx::Augment::Utils
);

had_no_warnings;
done_testing;
