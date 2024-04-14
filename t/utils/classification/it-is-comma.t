
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_comma @_ };
arrange_document       { q (1,2, 3) };

assume_ppi q (should match token ',')
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Operator:: => q (,), { column_number => 2 }),
		expect_element (PPI::Token::Operator:: => q (,), { column_number => 4 }),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ { next_sibling => sub { it_is_token_number } } ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Operator:: => q (,), { column_number => 2 }),
	);

had_no_warnings;
done_testing;

