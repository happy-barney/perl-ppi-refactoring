
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { & it_is_sub_definition };
arrange_document       { <<'END_OF_DOCUMENT' };
sub foo { ... }
my sub foo { ... }
sub bar;
sub { }
END_OF_DOCUMENT

assume_ppi q (should match function declaration(s))
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Sub:: => q (sub foo { ... })),
		expect_element (PPI::Statement::Sub:: => q (my sub foo { ... })),
	);

had_no_warnings;
done_testing;

