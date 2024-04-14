
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_ppi q (should classify using existing 'next_sibling')
	=> document       => q (1 2; 3)
	=> classification => sub { its_snext_sibling { it_is_token_number } }
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Number::     => q (1)),    # '2'
		expect_element (PPI::Token::Whitespace:: => q ( )),    # '2'
	);

had_no_warnings;
done_testing;

