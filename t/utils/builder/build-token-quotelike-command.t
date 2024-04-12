
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_quotelike_command };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token when it doesn't look like command)
	=> content => [ q (m (123)) ]
	=> expect  => undef
	;

assume_builder q (should build token representing 'qx//')
	=> content => [ q (qx (123) ) ]
	=> expect  => expect_element (
		PPI::Token::QuoteLike::Command:: => q (qx (123)),
	);

had_no_warnings;
done_testing;
