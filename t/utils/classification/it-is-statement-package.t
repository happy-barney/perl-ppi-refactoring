
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_package @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
package Foo;
package Bar { ... }
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Package)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Package:: => q (package Foo;)),
		expect_element (PPI::Statement::Package:: => q (package Bar { ... })),
	);

had_no_warnings;
done_testing;

