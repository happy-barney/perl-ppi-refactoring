
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_condition @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
if (1) { ... }
next if 2;
next if (3);
while (4) { ... };
do { ... } while (5);
END_OF_DOCUMENT

assume_ppi q (should match all instances)
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::Condition:: => q ((1))),
		expect_element (PPI::Structure::Condition:: => q ((3))),
		expect_element (PPI::Structure::Condition:: => q ((4))),
		expect_element (PPI::Structure::Condition:: => q ((5))),
	);

had_no_warnings;
done_testing;

