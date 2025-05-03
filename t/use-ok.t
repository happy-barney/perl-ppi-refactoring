
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw ( :no_end_test had_no_warnings );

use_ok $_
	for (
		q (PPIx::Augment),
		q (PPIx::Augment::Internals),
	);

had_no_warnings;
done_testing;
