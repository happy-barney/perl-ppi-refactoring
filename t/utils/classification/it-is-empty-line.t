
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document       { <<'END_OF_DOCUMENT' };
sub foo;

sub bar;


sub baz;
END_OF_DOCUMENT

assume_ppi q (should match current element)
	=> classification => it_is_empty_line
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Whitespace:: => qq (\n), { line_number => 2 }),
		expect_element (PPI::Token::Whitespace:: => qq (\n), { line_number => 4 }),
		expect_element (PPI::Token::Whitespace:: => qq (\n), { line_number => 5 }),
	);

assume_ppi q (should match effective element)
	=> classification => sub { it_is_empty_line next_sibling next_sibling}
	=> expect         => expect_nodeset (
		expect_element (PPI::Statement::Sub::    => q  (sub foo;), { line_number => 1 }),
		expect_element (PPI::Statement::Sub::    => q  (sub bar;), { line_number => 3 }),
		expect_element (PPI::Token::Whitespace:: => qq (\n),       { line_number => 3 }),
	);

had_no_warnings;
done_testing;

