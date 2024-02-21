
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_for @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
for (1; 2; 3) { ... }
for (4, 5, 6) { ... }
END_OF_DOCUMENT

assume_ppi q (should match all instances)
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::For:: => q ((1; 2; 3))),
	);

had_no_warnings;
done_testing;

