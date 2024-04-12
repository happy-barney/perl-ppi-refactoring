
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_number_octal };

assume_builder q (shouldn't accept 'undef' as valid content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept empty string as valid content)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept non-octal content)
	=> content => [ q (foo) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept decimal zero)
	=> content => [ q (0) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept decimal zero with underlines)
	=> content => [ q (0__) ]
	=> expect  => undef
	;

assume_builder q (should accept octal number)
	=> content => [ q (0_1_) ]
	=> expect  => expect_element (PPI::Token::Number::Octal:: => q (0_1_))
	;

assume_builder q (should accept '-' sign)
	=> content => [ q (-01) ]
	=> expect  => expect_element (PPI::Token::Number::Octal:: => q (-01))
	;

assume_builder q (should accept v5.34 octal number)
	=> content => [ q (0o_1) ]
	=> expect  => expect_element (PPI::Token::Number::Octal:: => q (0o_1))
	;

assume_builder q (shouldn't allow '_' before v5.34 'o')
	=> content => [ q (0_o_1) ]
	=> expect  => undef
	;

had_no_warnings;
done_testing;
