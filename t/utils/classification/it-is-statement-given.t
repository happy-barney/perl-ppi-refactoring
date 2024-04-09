
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_given @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
given ($foo) { ... }
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Given)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Given:: => q (given ($foo) { ... })),
	);

had_no_warnings;
done_testing;

