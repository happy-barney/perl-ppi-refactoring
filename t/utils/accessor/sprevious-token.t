
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { sprevious_token @_ };
arrange_document { q (1 2;3 ) };

assume_accessor q (should return previous token following current token)
	=> where    => where { it_is_token_number q (2) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (1)),
	);

assume_accessor q (should return previous token following current token even not under same parent)
	=> where    => where { it_is_token_structure q (;) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (2)),
	);

assume_accessor q (should return previous token following current node)
	=> where    => where { it_is_token_number q (3) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (;)),
	);

assume_accessor q (should return previous token following effective element)
	=> where    => where { it_is_token_number q (2) }
	=> accessor => sub { sprevious_token sprevious_token }
	=> expect   => expect_nodeset (
		expect_no_element,
	);

had_no_warnings;
done_testing;

