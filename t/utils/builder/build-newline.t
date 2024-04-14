
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_newline };

assume_builder q (should built whitespace token with single '\n')
	=> content => [ ]
	=> expect  => expect_element (PPI::Token::Whitespace:: => qq (\n))
	;

had_no_warnings;
done_testing;
