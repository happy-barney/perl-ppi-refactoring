
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_quotelike_readline @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
<>;
<FILE>;
<$file>;
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::QuoteLike::Readline::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::QuoteLike::Readline:: => q (<>)),
		expect_element (PPI::Token::QuoteLike::Readline:: => q (<FILE>)),
		expect_element (PPI::Token::QuoteLike::Readline:: => q (<$file>)),
	);

had_no_warnings;
done_testing;

