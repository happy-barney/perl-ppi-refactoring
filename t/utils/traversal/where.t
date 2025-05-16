
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { q (package foo { sub foo { my sub bar } }) };

assume_ppi_document q (where (&) block should receive PPI arguments)
	=> where  => where { $_[1]->isa (PPI::Token::Word::) }
	=> expect => expect_nodeset (
		expect_ppi_token_word (q (package)),
		expect_ppi_token_word (q (foo)),
		expect_ppi_token_word (q (sub)),
		expect_ppi_token_word (q (foo)),
		expect_ppi_token_word (q (my)),
		expect_ppi_token_word (q (sub)),
		expect_ppi_token_word (q (bar)),
	);

assume_ppi_document q (where (&) block should have $_ populated)
	=> where  => where { $_->isa (PPI::Token::Word::) }
	=> expect => expect_nodeset (
		expect_ppi_token_word (q (package)),
		expect_ppi_token_word (q (foo)),
		expect_ppi_token_word (q (sub)),
		expect_ppi_token_word (q (foo)),
		expect_ppi_token_word (q (my)),
		expect_ppi_token_word (q (sub)),
		expect_ppi_token_word (q (bar)),
	);

had_no_warnings;
done_testing;

