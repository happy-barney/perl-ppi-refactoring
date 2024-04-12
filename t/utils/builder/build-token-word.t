use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_word };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build token whitespace from non-identifier content)
	=> content => [ q ( 0 ) ]
	=> expect  => undef
	;

assume_builder q (should build token word)
	=> content => [ q (package) ]
	=> expect  => expect_element (PPI::Token::Word:: => q (package))
	;

had_no_warnings;
done_testing;
