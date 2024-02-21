
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_data @_ };
arrange_document       { <<'DATA_OF_DOCUMENT' };
__DATA__
foo
DATA_OF_DOCUMENT

assume_ppi q (parsing PPI document with __DATA__)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Data:: => qq (foo\n)),
	);

had_no_warnings;
done_testing;
