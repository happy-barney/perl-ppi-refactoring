
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { &next_token };
arrange_document { q (1 2;3 ) };

assume_accessor q (should return next token following current token)
	=> where    => where { it_is_token q (1) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Whitespace:: => q ( )),
	);

assume_accessor q (should return next token following current token even not under same parent)
	=> where    => where { it_is_token q (;) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (3)),
	);

assume_accessor q (should return next token following current node)
	=> where    => where { it_is_node q (1 2;) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (3)),
	);

assume_accessor q (should return next token following effective element)
	=> where    => where { it_is_token_number q (1) }
	=> accessor => sub { next_token next_token }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (2)),
	);

had_no_warnings;
done_testing;

