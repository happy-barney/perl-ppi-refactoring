
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_number_binary @_ };
arrange_document       { q ( 0 0b1 0b10 0b100 0.2 0x3 04 v0.5 ) };

assume_ppi q (should match only binary numbers)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Binary:: => q (0b1)),
		expect_element (PPI::Token::Number::Binary:: => q (0b10)),
		expect_element (PPI::Token::Number::Binary:: => q (0b100)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ +{ literal => sub { $_[0] < 3 } } ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Binary:: => q (0b1)),
		expect_element (PPI::Token::Number::Binary:: => q (0b10)),
	);

had_no_warnings;
done_testing;

