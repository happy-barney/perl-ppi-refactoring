
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

my $document = ppi_document <<'DOCUMENT';
foo;
package bar { baz };
{
	foo2;
}
DOCUMENT

assume_ppi q (ppi_exclude () should allow descend into children)
	=> document => $document
	=> where    => sub {
		return ppi_include if $_[1]->isa (PPI::Token::Word::);
		return ppi_exclude;
	}
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::, q (foo)),
		expect_element (PPI::Token::Word::, q (package)),
		expect_element (PPI::Token::Word::, q (bar)),
		expect_element (PPI::Token::Word::, q (baz)),
		expect_element (PPI::Token::Word::, q (foo2)),
	);

assume_ppi q (ppi_exclude_all () should prohibit descend into children)
	=> document => $document
	=> where    => sub {
		return ppi_include if $_[1]->isa (PPI::Token::Word::);
		return ppi_exclude_all if $_[1]->isa (PPI::Statement::Package::);
		return ppi_exclude;
	}
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::, q (foo)),
		expect_element (PPI::Token::Word::, q (foo2)),
	);

had_no_warnings;
done_testing;
