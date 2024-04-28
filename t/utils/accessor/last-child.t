
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { last_child @_ };
arrange_document { <<'END_OF_DOCUMENT' };
1 2;
package Foo { 3 }
END_OF_DOCUMENT

assume_accessor q (should return last child of document)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Whitespace:: => qq (\n)),
	);

assume_accessor q (should return last child of selected node)
	=> where    => where { it_is_statement_package }
	=> expect   => expect_nodeset (
		expect_element (PPI::Structure::Block:: => q ({ 3 })),
	);

assume_accessor q (last child of PPI::Element shouldn't exist)
	=> where    => where { it_is_token_number q (2) }
	=> expect   => expect_nodeset (
		expect_no_element
	);

had_no_warnings;
done_testing;

