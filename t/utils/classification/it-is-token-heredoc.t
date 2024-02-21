
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_heredoc @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
say <<'FOO', <<'BAR'
1 2 3
FOO
4 5 6
BAR
END_OF_DOCUMENT

assume_ppi q (parsing PPI document with heredoc)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::HereDoc:: => q (<<'FOO')),
		expect_element (PPI::Token::HereDoc:: => q (<<'BAR')),
	);

had_no_warnings;
done_testing;
