
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_number_float @_ };
arrange_document       { q ( 0 0b1 0.2 1. 1e2 0x3 04 v0.5 ) };

assume_ppi q (should match only float numbers)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::Float:: => q (0.2)),
		expect_element (PPI::Token::Number::Float:: => q (1.)),
		expect_element (PPI::Token::Number::Exp::   => q (1e2)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ qr (^1) ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Float:: => q (1.)),
		expect_element (PPI::Token::Number::Exp::   => q (1e2)),
	);

had_no_warnings;
done_testing;

