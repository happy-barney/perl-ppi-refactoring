
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_ppi q (should classify using 'sprevious_sibling')
	=> document       => q (1 2; 3)
	=> classification => sub { its_sprevious_sibling { it_is_token_number } }
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Whitespace:: => q ( ), { column_number => 2 }),
		expect_element (PPI::Token::Number::     => q (2)),
		expect_element (PPI::Token::Structure::  => q (;), { column_number => 4 }),
	);

had_no_warnings;
done_testing;

