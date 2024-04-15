
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { <<'END_OF_DOCUMENT' };
package Foo { 1 } ;
END_OF_DOCUMENT

assume_ppi q (should classify elements by it's parent)
	=> classification => sub { its_parent { it_is_statement_package } }
	=> expect         => expect_nodeset (
		expect_element (PPI::Token::Word::       => q (package)),
		expect_element (PPI::Token::Whitespace:: => q ( )),
		expect_element (PPI::Token::Word::       => q (Foo)),
		expect_element (PPI::Token::Whitespace:: => q ( )),
		expect_element (PPI::Structure::Block::  => q ({ 1 })),
	);

had_no_warnings;
done_testing;

