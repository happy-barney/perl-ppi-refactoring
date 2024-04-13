
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { first_child @_ };
arrange_document { <<'END_OF_DOCUMENT' };
1 2;
package Foo { 3 }
END_OF_DOCUMENT

assume_accessor q (should return first element of document)
	=> expect   => expect_nodeset (
		expect_element (PPI::Statement:: => q (1 2;)),
	);

assume_accessor q (should return first element of selected node)
	=> where    => where { it_is_statement_package }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Word:: => q (package)),
	);

assume_accessor q (should return first element of of element shouldn't exist)
	=> where    => where { it_is_token_number q (2) }
	=> expect   => expect_nodeset (
		expect_no_element
	);

had_no_warnings;
done_testing;

