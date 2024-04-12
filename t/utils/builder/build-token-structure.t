use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_structure };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build token whitespace from non-token-structure content)
	=> content => [ q ( 0 ) ]
	=> expect  => undef
	;

assume_builder q (should build token semicolon)
	=> content => [ q (;) ]
	=> expect  => expect_element (PPI::Token::Structure:: => q (;))
	;

assume_builder q (should build token left paren)
	=> content => [ q <(> ]
	=> expect  => expect_element (PPI::Token::Structure:: => q <(>)
	;

assume_builder q (should build token right paren)
	=> content => [ q <)> ]
	=> expect  => expect_element (PPI::Token::Structure:: => q <)>)
	;

had_no_warnings;
done_testing;
