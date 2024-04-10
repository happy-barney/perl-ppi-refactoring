
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_quotelike_command @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
qx <...>;
`...`;
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::QuoteLike::Command::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::QuoteLike::Command:: => q (qx <...>)),
	);

had_no_warnings;
done_testing;

