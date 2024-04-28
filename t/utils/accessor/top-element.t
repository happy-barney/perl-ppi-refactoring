
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { q (1 2 3) };

assume_accessor q (should return previous significant sibling of current element)
	=> where    => where { it_is_token_number q (2) }
	=> accessor => sub { top_element }
	=> expect   => expect_nodeset (
		expect_element (PPI::Document:: => q (1 2 3)),
	);

had_no_warnings;
done_testing;
