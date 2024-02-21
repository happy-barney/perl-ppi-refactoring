
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_end @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
foo;
__END__
bar
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::End)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::End:: => qq (__END__\nbar\n)),
	);

had_no_warnings;
done_testing;

