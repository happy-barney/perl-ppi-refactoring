use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_structure @_ };
arrange_document { q (1; { 2; }) };

assume_ppi q (should match any instance of PPI::Token::Structure::)
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (;), { column_number => 2 }),
		expect_element (PPI::Token::Structure:: => q ({), { column_number => 4 }),
		expect_element (PPI::Token::Structure:: => q (;), { column_number => 7 }),
		expect_element (PPI::Token::Structure:: => q (}), { column_number => 9 }),
	);

assume_ppi q (should match additional condition(s) as well)
	=> conditions     => [ q (;) ]
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (;), { column_number => 2 }),
		expect_element (PPI::Token::Structure:: => q (;), { column_number => 7 }),
	);

had_no_warnings;
done_testing;

