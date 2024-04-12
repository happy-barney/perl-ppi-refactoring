
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { last_token @_ };
arrange_document { <<'END_OF_DOCUMENT' };
1 2;
package Foo { 3 }
4
END_OF_DOCUMENT

assume_accessor q (should return last token of document)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Whitespace:: => qq (\n)),
	);

assume_accessor q (should return last token of selected node)
	=> where    => where { it_is_statement_package }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (})),
	);

assume_accessor q (should return element as its last token)
	=> where    => where { it_is_token_number q (1) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (1)),
	);

had_no_warnings;
done_testing;

