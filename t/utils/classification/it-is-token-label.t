
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_label @_ };
arrange_document       { q (OUTER : while (0) { INNER: }) };

assume_ppi q (should match instance of PPI::Token::Label)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Label:: => q (OUTER :)),
		expect_element (PPI::Token::Label:: => q (INNER:)),
	);

assume_ppi q (should accept additional arguments)
	=> conditions => [ qr ([ ]) ]
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Label:: => q (OUTER :)),
	);

had_no_warnings;
done_testing;

