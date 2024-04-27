
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_token_regexp_transliterate };

assume_builder q (shouldn't accept 'undef' content)
	=> content => [ undef ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token from empty string)
	=> content => [ q () ]
	=> expect  => undef
	;

assume_builder q (shouldn't build a token when it doesn't look like transliteration)
	=> content => [ q (s (123) (456)) ]
	=> expect  => undef
	;

assume_builder q (should build token representing 'tr' transliteration)
	=> content => [ q (tr [123] [456]) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Transliterate:: => q (tr [123] [456]), {
			get_match_string      => q (123),
			get_substitute_string => q (456),
		},
	);

assume_builder q (should build token representing 'y' transliteration)
	=> content => [ q (y/123/456/) ]
	=> expect  => expect_element (
		PPI::Token::Regexp::Transliterate:: => q (y/123/456/), {
			get_match_string      => q (123),
			get_substitute_string => q (456),
		},
	);

had_no_warnings;
done_testing;
