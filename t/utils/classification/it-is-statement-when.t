
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_when @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
given ($foo) {
    when (m (f)) { foo ($_) }
    when (m (b)) { bar ($_) }
    default { baz ($_) }
}
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::When)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::When:: => q (when (m (f)) { foo ($_) })),
		expect_element (PPI::Statement::When:: => q (when (m (b)) { bar ($_) })),
		expect_element (PPI::Statement::When:: => q (default { baz ($_) })),
	);

had_no_warnings;
done_testing;

