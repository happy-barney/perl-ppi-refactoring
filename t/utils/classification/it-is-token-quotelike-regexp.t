
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_quotelike_regexp @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
qr (1 2 3);
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::QuoteLike::Regexp::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::QuoteLike::Regexp:: => q (qr (1 2 3))),
	);

had_no_warnings;
done_testing;

