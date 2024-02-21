
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { &it_is_token_word };
arrange_document       { <<'END_OF_DOCUMENT' };
package Foo {
    sub Bar {
        false => q (true)
    }
}
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Word::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Word:: => q (package)),
		expect_element (PPI::Token::Word:: => q (Foo)),
		expect_element (PPI::Token::Word:: => q (sub)),
		expect_element (PPI::Token::Word:: => q (Bar)),
		expect_element (PPI::Token::Word:: => q (false)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ qr (^ \p{Lu})x ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Word:: => q (Foo)),
		expect_element (PPI::Token::Word:: => q (Bar)),
	);

had_no_warnings;
done_testing;

