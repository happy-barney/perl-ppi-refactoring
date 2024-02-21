
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_operator @_ };
arrange_document       { q ($foo->method (bar => ! baz >> +2)) };

assume_ppi q (parsing PPI document with operators)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Operator:: => q (->)),
		expect_element (PPI::Token::Operator:: => q (=>)),
		expect_element (PPI::Token::Operator:: => q (!)),
		expect_element (PPI::Token::Operator:: => q (>>)),
		expect_element (PPI::Token::Operator:: => q (+)),
	);

assume_ppi q (parsing PPI document with operators using additional conditions)
	=> conditions => [ qr (.>) ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Operator:: => q (->)),
		expect_element (PPI::Token::Operator:: => q (=>)),
		expect_element (PPI::Token::Operator:: => q (>>)),
	);

had_no_warnings;
done_testing;
