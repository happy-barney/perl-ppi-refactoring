
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_number_hex };

assume_builder q (shouldn't accept 'undef' as valid content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept empty string as valid content)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept non-hex content)
	=> content => [ q (foo) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept decimal zero)
	=> content => [ q (0) ]
	=> expect  => undef
	;

assume_builder q (should accept hex number)
	=> content => [ q (0x_1_a_B_) ]
	=> expect  => expect_element (PPI::Token::Number::Hex:: => q (0x_1_a_B_))
	;

assume_builder q (should accept '-' sign)
	=> content => [ q (-0X1) ]
	=> expect  => expect_element (PPI::Token::Number::Hex:: => q (-0X1))
	;

assume_builder q (should accept hex zero)
	=> content => [ q (-0X_) ]
	=> expect  => expect_element (PPI::Token::Number::Hex:: => q (-0X_), { literal => 0 })
	;

had_no_warnings;
done_testing;
