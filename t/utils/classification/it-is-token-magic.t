
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_magic @_ };
arrange_document       { q ( $$ $foo ${^Foo} ) };

assume_ppi q (should match any instance of PPI::Token::Magic::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Magic:: => q ($$)),
		expect_element (PPI::Token::Magic:: => q (${^Foo})),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ q ($$) ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Magic:: => q ($$)),
	);

had_no_warnings;
done_testing;

