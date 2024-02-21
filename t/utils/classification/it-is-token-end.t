
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_end @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
__END__
foo
END_OF_DOCUMENT

assume_ppi q (parsing PPI document with __END__)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::End:: => qq (foo\n)),
	);

had_no_warnings;
done_testing;
