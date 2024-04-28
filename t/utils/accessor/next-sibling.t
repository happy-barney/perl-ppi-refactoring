
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { q (1 2;3 ) };

assume_accessor q (should return next sibling of current element)
	=> where    => where { it_is_token_number q (1) }
	=> accessor => sub { next_sibling }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Whitespace:: => q ( )),
	);

assume_accessor q (should return next sibling of effective element)
	=> where    => where { it_is_token_number q (1) }
	=> accessor => sub { next_sibling next_sibling },
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number:: => q (2)),
	);

had_no_warnings;
done_testing;

