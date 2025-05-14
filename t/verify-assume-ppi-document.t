
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_ppi_document q (should recognize 'where' clause)
	=> document => q (1;2;4)
	=> where    => sub { $_[1]->isa (PPI::Token::Number::) }
	=> expect   => expect_nodeset (
		expect_ppi_token_number (q (1)),
		expect_ppi_token_number (q (2)),
		expect_ppi_token_number (q (4)),
	);

assume_ppi_document q (should recognize 'first' clause)
	=> document => q (1;2;4)
	=> first    => sub { $_[1]->isa (PPI::Token::Number::) }
	=> expect   => expect_nodeset (
		expect_ppi_token_number (q (1))
	);

had_no_warnings;
done_testing;
