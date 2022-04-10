
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

my $following_empty_line = augmented_document (<<'DOCUMENT');
foo;

bar;
DOCUMENT

check_ppi "following empty line"
	=> document => $following_empty_line
	=> where    => where { it_is_followed_by_empty_line }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Statement' => "foo;"),
	);

had_no_warnings;

done_testing;
