
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_given @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
given (foo) {
}
END_OF_DOCUMENT

assume_ppi q (should match all instances)
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::Given:: => q ((foo))),
	);

had_no_warnings;
done_testing;

