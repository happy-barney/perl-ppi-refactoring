
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { q (package foo { sub foo { my sub bar } }) };

assume_ppi q (invoke (&) block should receive PPI arguments)
	=> where  => where  { $_[1]->isa (PPI::Token::Word::) }
	=> invoke => invoke { $_[1]->set_content (q (new_foo)) if $_[1] eq q (foo) }
	=> expect => expect_nodeset (
		expect_element (PPI::Token::Word::, q (package)),
		expect_element (PPI::Token::Word::, q (new_foo)),
		expect_element (PPI::Token::Word::, q (sub)),
		expect_element (PPI::Token::Word::, q (new_foo)),
		expect_element (PPI::Token::Word::, q (my)),
		expect_element (PPI::Token::Word::, q (sub)),
		expect_element (PPI::Token::Word::, q (bar)),
	);

assume_ppi q (invoke (&) block should have $_ populated)
	=> where  => where { $_->isa (PPI::Token::Word::) }
	=> invoke => invoke { $_->set_content (q (new_foo)) if $_ eq q (foo) }
	=> expect => expect_nodeset (
		expect_element (PPI::Token::Word::, q (package)),
		expect_element (PPI::Token::Word::, q (new_foo)),
		expect_element (PPI::Token::Word::, q (sub)),
		expect_element (PPI::Token::Word::, q (new_foo)),
		expect_element (PPI::Token::Word::, q (my)),
		expect_element (PPI::Token::Word::, q (sub)),
		expect_element (PPI::Token::Word::, q (bar)),
	);

had_no_warnings;
done_testing;

