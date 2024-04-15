
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

my $document = ppi_document (q ( 1 2; 3));

assume_ppi q (should classify using existing 'next_sibling')
	=> document       => q (1 2; 3)
	=> classification => sub { its_next_sibling { it_is_token_whitespace } }
	=> expect         => expect_nodeset (
		expect_element (PPI::Statement::     => q (1 2;)),
		expect_element (PPI::Token::Number:: => q (1)),
	);

had_no_warnings;
done_testing;

