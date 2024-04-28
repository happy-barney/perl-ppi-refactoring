
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { <<'END_OF_DOCUMENT' };
package Foo { }
END_OF_DOCUMENT

assume_accessor q (should return all significant children of Statement::Package)
	=> where    => where { it_is_statement_package }
	=> accessor => sub { schildren }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::       => q (package)),
		expect_element (PPI::Token::Word::       => q (Foo)),
		expect_element (PPI::Structure::Block::  => ()),
	);

assume_accessor q (should return children using starting index)
	=> where    => where { it_is_statement_package }
	=> accessor => sub { schildren 1 }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::       => q (Foo)),
		expect_element (PPI::Structure::Block::  => ()),
	);

assume_accessor q (should return children indexed children)
	=> where    => where { it_is_statement_package }
	=> accessor => sub { schildren -3, -2 }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::       => q (package)),
		expect_element (PPI::Token::Word::       => q (Foo)),
	);

had_no_warnings;
done_testing;

