
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_sub @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
sub foo;
sub foo ($) { }
sub { }
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Sub)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Sub:: => q (sub foo;)),
		expect_element (PPI::Statement::Sub:: => q (sub foo ($) { })),
	);

had_no_warnings;
done_testing;

