
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_package_declaration @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
package Alpha;
package Beta v1.2.3;
package Gamma { };
package Delta v1.2.3 { };
END_OF_DOCUMENT

assume_ppi q (should match only package statements with block)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Package:: => q (package Alpha;)),
		expect_element (PPI::Statement::Package:: => q (package Beta v1.2.3;)),
	);

had_no_warnings;
done_testing;

