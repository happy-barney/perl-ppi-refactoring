
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_block };

assume_builder q (should build empty block)
	=> content => [ ]
	=> expect  => expect_element (PPI::Structure::Block:: => q ({}))
	;

assume_builder q (should build block with some content)
	=> content => [
		build_token_whitespace q ( ),
		build_token_word       q (foo),
		build_token_whitespace q ( ),
		build_token_operator   q (=),
		build_token_whitespace q ( ),
		build_token_number     q (1),
		build_semicolon,
		build_token_whitespace q ( ),
	]
	=> expect  => expect_element (PPI::Structure::Block:: => q ({ foo = 1; }))
	;

had_no_warnings;
done_testing;
