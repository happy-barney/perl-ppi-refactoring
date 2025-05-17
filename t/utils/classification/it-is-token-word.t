
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

assume_ppi_document q (should match any instance of PPI::Token::Word::)
	=> expect     => expect_nodeset (
		expect_ppi_token_word (q (package)),
		expect_expect_ppi_token_word (q (Foo)),
		expect_expect_ppi_token_word (q (sub)),
		expect_expect_ppi_token_word (q (Bar)),
		expect_expect_ppi_token_word (q (false)),
	);

assume_ppi_document q (should accept additional conditions)
	=> conditions => [ qr (^ \p{Lu})x ]
	=> expect     => expect_nodeset (
		expect_expect_ppi_token_word (q (Foo)),
		expect_expect_ppi_token_word (q (Bar)),
	);

had_no_warnings;
done_testing;
