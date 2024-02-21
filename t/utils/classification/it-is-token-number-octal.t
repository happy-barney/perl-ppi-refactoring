
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_number_octal @_ };
arrange_document       { q ( 0 0b1 0.2 1e2 0x3 04 0077 v0.5 ) };

assume_ppi q (should match only octal numbers)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::Octal:: => q (04)),
		expect_element (PPI::Token::Number::Octal:: => q (0077)),
	);

assume_ppi q (should match only octal numbers)
	=> conditions => [ qr (7) ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Octal:: => q (0077)),
	);

had_no_warnings;
done_testing;

