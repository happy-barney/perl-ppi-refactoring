
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_number_version };

assume_builder q (shouldn't accept 'undef' as valid content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept empty string as valid content)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept non-version content)
	=> content => [ q (foo) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept decimal number)
	=> content => [ q (5) ]
	=> expect  => undef
	;

assume_builder q (shouldn't accept float number)
	=> content => [ q (5.14) ]
	=> expect  => undef
	;

assume_builder q (should accept version number)
	=> content => [ q (v5.14) ]
	=> expect  => expect_element (PPI::Token::Number::Version:: => q (v5.14))
	;

had_no_warnings;
done_testing;
