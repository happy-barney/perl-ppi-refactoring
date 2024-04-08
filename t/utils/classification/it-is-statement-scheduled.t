
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_scheduled @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
INIT { ... }
BEGIN { ... }
ADJUST { ... }
defer { ... }
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Scheduled)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Scheduled:: => q (INIT { ... })),
		expect_element (PPI::Statement::Scheduled:: => q (BEGIN { ... })),
	);

had_no_warnings;
done_testing;

