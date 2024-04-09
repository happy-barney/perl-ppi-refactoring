
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_compound @_ };
arrange_document       { <<'COMPOUND_OF_DOCUMENT' };
if (...) { ... }
if (...) { ... } else { ... }
$foo if ...;
while (...) { ... }
do { ... } while ...;
COMPOUND_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Compound)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Compound:: => qq (if (...) { ... })),
		expect_element (PPI::Statement::Compound:: => qq (if (...) { ... } else { ... })),
		expect_element (PPI::Statement::Compound:: => qq (while (...) { ... })),
	);

had_no_warnings;
done_testing;

