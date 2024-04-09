
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

act { PPIx::Augment::Utils::_compare_value (@_) }
	q (value),
	q (condition),
	;

arrange { value => q (123) };

ok  q (should match 'undef' as true)
	=> with_condition => undef
	;

ok  q (should match regex (positive match))
	=> with_condition => qr (^1)
	;

nok q (should match regex (negative match))
	=> with_condition => qr (^2)
	;

ok  q (should match sub (positive match))
	=> with_condition => sub { $_[0] % 3 == 0}
	;

nok q (should match sub (negative match))
	=> with_condition => sub { $_[0] % 2 == 0}
	;

had_no_warnings;
done_testing;
