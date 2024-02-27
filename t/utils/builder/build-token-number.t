
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_number };

assume_builder q (shouldn't accept 'undef' as valid content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (should recognize decimal number)
	=> content => [ q (0) ]
	=> expect  => expect_element (PPI::Token::Number:: => q (0))
	;

assume_builder q (should recognize exp number)
	=> content => [ q (0e0) ]
	=> expect  => expect_element (PPI::Token::Number::Exp:: => q (0e0))
	;

assume_builder q (should recognize float number)
	=> content => [ q (.0) ]
	=> expect  => expect_element (PPI::Token::Number::Float:: => q (.0))
	;

assume_builder q (should recognize hex number)
	=> content => [ q (0x0) ]
	=> expect  => expect_element (PPI::Token::Number::Hex:: => q (0x0))
	;

assume_builder q (should recognize octal number)
	=> content => [ q (00) ]
	=> expect  => expect_element (PPI::Token::Number::Octal:: => q (00))
	;

had_no_warnings;
done_testing;
