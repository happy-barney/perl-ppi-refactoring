
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_comma };

assume_builder q (should built operator token with ',')
	=> expect  => expect_element (PPI::Token::Operator:: => q (,))
	;

had_no_warnings;
done_testing;
