
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_null @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
foo;
;
for (;;) { ... }
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Null)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Null:: => q (;), { line_number => 2 }),
		expect_element (PPI::Statement::Null:: => q (;), { line_number => 3, column_number => 6 }),
		expect_element (PPI::Statement::Null:: => q (;), { line_number => 3, column_number => 7 }),
	);

had_no_warnings;
done_testing;

