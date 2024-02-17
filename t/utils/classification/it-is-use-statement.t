
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

not 1 and check_ppi "should find use statements"
	=> where    => where { it_is_use_statement }
	=> document => my $source = <<'		DOCUMENT'
		use Foo;
		use Bar { }
		no Baz;
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement::Include')
			& methods (module => 'Foo')
			,
		expect_element ('PPI::Statement::Include')
			& methods (module => 'Bar')
			,
	);

check_ppi "should find use statements in context"
	=> where    => where { it_is_use_statement { context_namespace => 'AAA' } }
	=> document => <<'		DOCUMENT'
		package AAA;
		use Foo;
		package BBB;
		use Bar { }
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement::Include')
			& methods (module => 'Foo')
			& expect_context_namespace ('AAA')
			,
	);

had_no_warnings;
done_testing;

