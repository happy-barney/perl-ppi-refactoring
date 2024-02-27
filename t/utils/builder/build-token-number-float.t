
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_number_float };

assume_builder q (shouldn't accept 'undef' as valid content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept empty string as valid content)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept non-numeric)
	=> content => [ q (foo) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept non-float)
	=> content => [ q (0) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept dot)
	=> content => [ q (.) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept negative dot)
	=> content => [ q (-.) ]
	=> expect  => undef
	;

assume_builder q (should accept float number)
	=> content => [ q (0.1) ]
	=> expect  => expect_element (PPI::Token::Number::Float:: => q (0.1))
	;

assume_builder q (should accept float number with leading dot)
	=> content => [ q (.1) ]
	=> expect  => expect_element (PPI::Token::Number::Float:: => q (.1))
	;

assume_builder q (should accept float number with trailing dot)
	=> content => [ q (1.) ]
	=> expect  => expect_element (PPI::Token::Number::Float:: => q (1.))
	;

assume_builder q (should accept '-' sign)
	=> content => [ q (-.1) ]
	=> expect  => expect_element (PPI::Token::Number::Float:: => q (-.1))
	;

assume_builder q (should accept exponential numbers)
	=> content => [ q (.1e+11) ]
	=> expect  => expect_element (PPI::Token::Number::Exp:: => q (.1e+11))
	;

had_no_warnings;
done_testing;
