
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_number_decimal };

assume_builder q (shouldn't accept 'undef' as valid content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept empty string as valid content)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept non-numeric content)
	=> content => [ q (foo) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept underlined identifier)
	=> content => [ q (_1) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept float numbers)
	=> content => [ q (0.1) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept binary numbers)
	=> content => [ q (0b1) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept octal numbers)
	=> content => [ q (0_1) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept v5.34 octal numbers)
	=> content => [ q (0o1) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept hex numbers)
	=> content => [ q (0x1) ]
	=> expect  => undef
	;

assume_builder q (should accept decimal zero)
	=> content => [ q (0_) ]
	=> expect  => expect_element (PPI::Token::Number:: => q (0_))
	;

assume_builder q (should accept decimal number)
	=> content => [ q (123) ]
	=> expect  => expect_element (PPI::Token::Number:: => q (123))
	;

assume_builder q (should accept '-' sign)
	=> content => [ q (-0) ]
	=> expect  => expect_element (PPI::Token::Number:: => q (-0))
	;

had_no_warnings;
done_testing;
