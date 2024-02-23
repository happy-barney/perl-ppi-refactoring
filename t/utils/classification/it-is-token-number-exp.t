
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_number_exp @_ };
arrange_document       { q ( 0 0b1 0.2 1e3 1e2 0x3 04 v0.5 ) };

assume_ppi q (should match only float numbers)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::Exp:: => q (1e3)),
		expect_element (PPI::Token::Number::Exp:: => q (1e2)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ qr (2) ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Exp:: => q (1e2)),
	);

had_no_warnings;
done_testing;

