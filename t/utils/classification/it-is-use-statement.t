
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_use_statement @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
use v5.14;
use strict;
no warnings q (bar);
use Module v2024.4;
require Module;
require q (file.pl);
END_OF_DOCUMENT

assume_ppi q (should match only PPI::Statement::Include instances using keyword 'use')
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Include:: => q (use v5.14;)),
		expect_element (PPI::Statement::Include:: => q (use strict;)),
		expect_element (PPI::Statement::Include:: => q (use Module v2024.4;)),
	);

had_no_warnings;
done_testing;

