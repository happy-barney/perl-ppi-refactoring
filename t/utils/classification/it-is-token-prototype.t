
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Augment::Structure::Signature;

testing_classification { &it_is_token_prototype };
arrange_document       { <<'END_OF_DOCUMENT' };
sub foo ();
sub foo ($) :attr();
sub foo ($a, $b);
sub foo :prototype(&$);
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Prototype::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Prototype:: => q (()), { line_number => 1 }),
		expect_element (PPI::Token::Prototype:: => q (($)), { line_number => 2 }),
		expect_element (PPI::Token::Prototype:: => q (($a, $b)), { line_number => 3 }),
	);

assume_classification q (should match instance of PPI::Token::Prototype::)
	=> element    => build_token_prototype q (($))
	=> expect     => expect_true
	;

assume_classification q (should not match instance of PPIx::Augment::Structure::Signature::)
	=> element    => bless ({}, PPIx::Augment::Structure::Signature::)
	=> expect     => expect_false
	;

had_no_warnings;
done_testing;

