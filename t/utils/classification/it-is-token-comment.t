
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_comment @_ };
arrange_document       { <<'COMMENT_OF_DOCUMENT' };
#!/usr/bin/env perl
foo # comment
s (
# regexp token
) {
# replacement comment
}xe
COMMENT_OF_DOCUMENT

assume_ppi q (parsing PPI document with comments)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Comment:: => qq (#!/usr/bin/env perl\n)),
		expect_element (PPI::Token::Comment:: => qq (# comment)),
	);

had_no_warnings;
done_testing;
