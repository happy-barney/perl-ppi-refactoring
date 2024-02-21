
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_when @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
given (foo) {
    when (1) { ... }
    default { ... }
}
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Token::When)
	=> expect   => expect_nodeset (
		expect_element (PPI::Structure::When:: => q ((1))),
	);

had_no_warnings;
done_testing;

