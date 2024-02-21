
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_expression @_ };
arrange_document       { q ( @foo = (1, 2, 3)) };

assume_ppi q (should match instance of PPI::Statement::Expression)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Expression:: => q (1, 2, 3)),
	);

had_no_warnings;
done_testing;

