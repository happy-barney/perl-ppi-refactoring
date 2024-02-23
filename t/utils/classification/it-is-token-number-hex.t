
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_number_hex @_ };
arrange_document       { q ( 0 0b1 0.2 1e2 0x3 0x_10 v0.5 ) };

assume_ppi q (should match only hex numbers)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Hex:: => q (0x3)),
		expect_element (PPI::Token::Number::Hex:: => q (0x_10)),
	);

assume_ppi q (should apply additional conditions)
	=> conditions => [ qr (_) ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Hex:: => q (0x_10)),
	);

had_no_warnings;
done_testing;

