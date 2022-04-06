
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

my $preceding_empty_line = document (<<'DOCUMENT');
foo;

bar;
DOCUMENT

check_ppi "preceding empty line"
	=> document => $preceding_empty_line
	=> where    => where { it_is_preceeded_by_empty_line }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Statement' => "bar;"),
	);

had_no_warnings;

done_testing;
