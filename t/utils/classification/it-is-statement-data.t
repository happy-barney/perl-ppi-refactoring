
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_data @_ };
arrange_document       { <<'DATA_OF_DOCUMENT' };
foo;
__DATA__
bar
DATA_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Data)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Data:: => qq (__DATA__\nbar\n)),
	);

had_no_warnings;
done_testing;

