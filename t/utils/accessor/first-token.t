
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { first_token @_ };
arrange_document { <<'END_OF_DOCUMENT' };
1 2;
package Foo { 3 }
END_OF_DOCUMENT

assume_accessor q (should return first token of document)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (1)),
	);

assume_accessor q (should return first token of selected node)
	=> where    => where { it_is_statement_package }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word:: => q (package)),
	);

assume_accessor q (should return element as its first token)
	=> where    => where { it_is_token_number q (2) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (2)),
	);

had_no_warnings;
done_testing;

