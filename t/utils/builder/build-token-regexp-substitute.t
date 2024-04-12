
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_regexp_substitute };

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

assume_builder q (should build token representing 's//')
	=> content => [ q (s/123/456/x ) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Substitute:: => q (s/123/456/x), {
			get_match_string      => q (123),
			get_substitute_string => q (456),
			get_modifiers         => { x => 1 },
		},
	);

assume_builder q (should build token representing 's()//')
	=> content => [ q (s (123) /456/gr) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Substitute:: => q (s (123) /456/gr), {
			get_match_string      => q (123),
			get_substitute_string => q (456),
			get_modifiers         => { g => 1, r => 1 },
		},
	);

had_no_warnings;
done_testing;
