use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { & it_is_token_structure };
arrange_document { <<'END_OF_DOCUMENT' };
1;
{ 2; }
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Structure::)
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (;), { line_number => 1, column_number => 2 }),
		expect_element (PPI::Token::Structure:: => q ({), { line_number => 2, column_number => 1 }),
		expect_element (PPI::Token::Structure:: => q (;), { line_number => 2, column_number => 4 }),
		expect_element (PPI::Token::Structure:: => q (}), { line_number => 2, column_number => 6 }),
	);

assume_ppi q (should match additional condition(s) as well)
	=> conditions     => [ q (;) ]
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (;), { line_number => 1 }),
		expect_element (PPI::Token::Structure:: => q (;), { line_number => 2 }),
	);

had_no_warnings;
done_testing;

