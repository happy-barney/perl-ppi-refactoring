
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { <<'END_OF_DOCUMENT' };
package Foo { }
END_OF_DOCUMENT

assume_accessor q (should return first significant child of PPI::Statement::Package)
	=> where    => where { it_is_statement_package }
	=> accessor => sub { schild 0 }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::       => q (package)),
	);

assume_accessor q (should return penultimate significant child of PPI::Statement::Package)
	=> where    => where { it_is_statement_package }
	=> accessor => sub { schild -2 }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word::       => q (Foo)),
	);

assume_accessor q (should return 'no_element' when called on PPI::Element)
	=> where    => where { it_is_token_word q (Foo) }
	=> accessor => sub { schild 0 }
	=> expect   => expect_nodeset (
		expect_no_element
	);

had_no_warnings;
done_testing;

