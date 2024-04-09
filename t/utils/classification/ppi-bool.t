
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { <<'DOCUMENT' };
foo;
package bar { baz };
{
	foo2;
}
DOCUMENT

assume_ppi q (ppi_exclude () should allow descend into children)
	=> where    => where {
		return ppi_include if current->isa (PPI::Token::Word::);
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
	=> where    => where {
		return ppi_include     if current->isa (PPI::Token::Word::);
		return ppi_exclude_all if current->isa (PPI::Statement::Package::);
		return ppi_exclude;
	}
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::, q (foo)),
		expect_element (PPI::Token::Word::, q (foo2)),
	);

assume q (ppi_bool () converts any true value to ppi_include ())
	=> got    { ppi_bool (q (foo)) }
	=> expect { expect_ppi_include }
	;

assume q (ppi_bool () converts no_element () to ppi_exclude ())
	=> got    { ppi_bool (no_element) }
	=> expect { expect_ppi_exclude }
	;

assume q (ppi_bool () converts ppi_exclude_all () to ppi_exclude ())
	=> got    { ppi_bool (ppi_exclude_all) }
	=> expect { expect_ppi_exclude }
	;

had_no_warnings;
done_testing;
