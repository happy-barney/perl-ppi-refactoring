
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_include @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
use v5.14;
use strict;
no warnings q (bar);
use Module v2024.4;
require Module;
require q (file.pl);
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Include)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Include:: => q (use v5.14;)),
		expect_element (PPI::Statement::Include:: => q (use strict;)),
		expect_element (PPI::Statement::Include:: => q (no warnings q (bar);)),
		expect_element (PPI::Statement::Include:: => q (use Module v2024.4;)),
		expect_element (PPI::Statement::Include:: => q (require Module;)),
		expect_element (PPI::Statement::Include:: => q (require q (file.pl);)),
	);

had_no_warnings;
done_testing;

