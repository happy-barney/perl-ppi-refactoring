
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should build empty structure block"
	=> got    => create_structure_block ()
	=> expect => expect_element ('PPI::Structure::Block', "{}")
	;

it "should build structure block with content"
	=> got    => create_structure_block (
		create_token_word ('foo'),
		create_token_semicolon,
	)
	=> expect => expect_element ('PPI::Structure::Block', "{foo;}")
	;

had_no_warnings;

done_testing;
