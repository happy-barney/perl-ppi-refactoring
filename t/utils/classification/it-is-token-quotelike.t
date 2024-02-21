
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_quotelike @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
`...`;
<...>;
qx <...>;
qr <...>;
qw <...>;
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::QuoteLike)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::QuoteLike::Backtick:: => q (`...`)),
		expect_element (PPI::Token::QuoteLike::Readline:: => q (<...>)),
		expect_element (PPI::Token::QuoteLike::Command::  => q (qx <...>)),
		expect_element (PPI::Token::QuoteLike::Regexp::   => q (qr <...>)),
		expect_element (PPI::Token::QuoteLike::Words::    => q (qw <...>)),
	);

had_no_warnings;
done_testing;

