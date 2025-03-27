
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { q (1 2 3) };

assume_accessor q (should return next significant siblings of current element)
	=> where    => where { it_is_token_number q (2) }
	=> accessor => sub { snext_siblings }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::     => q (3)),
	);

assume_accessor q (should return next significant sibling of effective element)
	=> where    => where { it_is_token_number q (2) }
	=> accessor => sub { snext_siblings previous_sibling },
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::     => q (2)),
		expect_element (PPI::Token::Number::     => q (3)),
	);

had_no_warnings;
done_testing;

