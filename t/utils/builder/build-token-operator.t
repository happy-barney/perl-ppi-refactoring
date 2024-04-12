use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_operator };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build token from non-operator content)
	=> content => [ q ( 0 ) ]
	=> expect  => undef
	;

assume_builder q (should build token operator - punctual operators)
	=> content => [ q (++) ]
	=> expect  => expect_element (PPI::Token::Operator:: => q (++))
	;

assume_builder q (should build token operator - identifer-operator)
	=> content => [ q (and) ]
	=> expect  => expect_element (PPI::Token::Operator:: => q (and))
	;

had_no_warnings;
done_testing;
