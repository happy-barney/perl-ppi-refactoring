
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw ( :no_end_test had_no_warnings );

use_ok $_
	for (
		q (PPIx::Augment),
		q (PPIx::Augment::Internals),
		q (PPIx::Augment::Internals::Exporter),
        q (PPIx::Augment::Utils),
	);

had_no_warnings;
done_testing;
