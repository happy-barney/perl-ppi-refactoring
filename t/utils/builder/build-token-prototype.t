
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_prototype };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token when not with parentheses)
	=> content => [ q (&;@) ]
	=> expect  => undef
	;

assume_builder q (should build token representing prototype)
	=> content => [ q ((&;@)) ]
	=> expect  => expect_element (
		PPI::Token::Prototype:: => q ((&;@)),
		{ prototype => q (&;@) },
	);

had_no_warnings;
done_testing;
