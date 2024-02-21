
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_number_version @_ };
arrange_document       { q ( 0 0b1 0.2 1e2 0x3 04 v0.5 v2024.0.6 ) };

assume_ppi q (should match only v-strings)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Version:: => q (v0.5)),
		expect_element (PPI::Token::Number::Version:: => q (v2024.0.6)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ +{ literal => chr (2024) . chr (0) . chr (6) } ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Number::Version:: => q (v2024.0.6)),
	);

had_no_warnings;
done_testing;

