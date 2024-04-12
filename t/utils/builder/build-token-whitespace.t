
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_whitespace };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build token whitespace from non-whitespace content)
	=> content => [ q ( 0 ) ]
	=> expect  => undef
	;

assume_builder q (should build token whitespace)
	=> content => [ q (   ) ]
	=> expect  => expect_element (q (PPI::Token::Whitespace) => q (   ))
	;

had_no_warnings;
done_testing;
