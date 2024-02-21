
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement @_ };
arrange_document       { q ( @foo = (1, 2, 3)) };

assume_ppi q (should match instance of PPI::Statement)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::             => q (@foo = (1, 2, 3))),
		expect_element (PPI::Statement::Expression:: => q (1, 2, 3)),
	);

had_no_warnings;
done_testing;

