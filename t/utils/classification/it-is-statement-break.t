
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_break @_ };
arrange_document       { <<'BREAK_OF_DOCUMENT' };
next;
last;
redo;
goto;
return;
die;
BREAK_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Break)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Break:: => q (next;)),
		expect_element (PPI::Statement::Break:: => q (last;)),
		expect_element (PPI::Statement::Break:: => q (redo;)),
		expect_element (PPI::Statement::Break:: => q (goto;)),
		expect_element (PPI::Statement::Break:: => q (return;)),
	);

had_no_warnings;
done_testing;

