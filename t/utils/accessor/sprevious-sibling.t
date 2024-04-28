
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { q (1 2; 3) };

assume_accessor q (should return previous significant sibling of current element)
	=> where    => where { it_is_token_number q (2) }
	=> accessor => \ &sprevious_sibling
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (1)),
	);

assume_accessor q (should return previous significant sibling of effective element)
	=> where    => where { it_is_element q (;) }
	=> accessor => sub { sprevious_sibling sprevious_sibling }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (1)),
	);

had_no_warnings;
done_testing;
