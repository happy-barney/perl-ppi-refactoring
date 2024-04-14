
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { &snext_token };
arrange_document { q (1 2;3 ) };

assume_accessor q (should return next token following current token)
	=> where    => where { it_is (PPI::Token::, q (1)) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (2)),
	);

assume_accessor q (should return next token following current token even not under same parent)
	=> where    => where { it_is (PPI::Token::, q (;)) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (3)),
	);

assume_accessor q (should return next token following current node)
	=> where    => where { it_is (PPI::Node::, q (1 2;)) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (3)),
	);

assume_accessor q (should return next token following effective element)
	=> where    => where { it_is (PPI::Token::Number::, q (1)) }
	=> accessor => sub { snext_token snext_token }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Structure:: => q (;)),
	);

had_no_warnings;
done_testing;

