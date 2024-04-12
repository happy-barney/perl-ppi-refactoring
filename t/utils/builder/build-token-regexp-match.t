
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_regexp_match };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token when it doesn't look like substitution)
	=> content => [ q (tr (123) (456)) ]
	=> expect  => undef
	;

assume_builder q (should build token representing 'm//')
	=> content => [ q (m/123/x ) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Match:: => q (m/123/x), {
			get_match_string      => q (123),
			get_substitute_string => undef,
			get_modifiers         => { x => 1 },
		},
	);

assume_builder q (should build token representing '//')
	=> content => [ q (// ) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Match:: => q (//), {
			get_match_string      => q (),
			get_substitute_string => undef,
			get_modifiers         => { },
		},
	);

assume_builder q (should build token representing 'm()')
	=> content => [ q (m (123)) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Match:: => q (m (123)), {
			get_match_string      => q (123),
			get_substitute_string => undef,
			get_modifiers         => { },
		},
	);

had_no_warnings;
done_testing;
