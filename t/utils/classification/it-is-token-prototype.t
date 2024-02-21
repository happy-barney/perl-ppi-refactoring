
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_prototype @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
sub foo ();
sub foo :attr() ($);
sub foo ($) :attr();
sub foo ($a, $b);
sub foo :prototype(&$);
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Prototype::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Prototype:: => q (()), { line_number => 1 }),
		#expect_element (PPI::Token::Prototype:: => q (($)), { line_number => 1 }),
		expect_element (PPI::Token::Prototype:: => q (($)), { line_number => 3 }),
		expect_element (PPI::Token::Prototype:: => q (($a, $b)), { line_number => 4 }),
	);

had_no_warnings;
done_testing;

