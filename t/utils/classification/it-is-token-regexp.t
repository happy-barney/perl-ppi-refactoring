
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_regexp @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
ref // 0;
//;
qr (...);
m<...>x;
s (...) (...);
tr (...) (...);
y (...) (...);
END_OF_DOCUMENT

assume_ppi q (should match any child of PPI::Token::Regexp)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Regexp::Match::         => q (//), { line_number => 2 }),
		expect_element (PPI::Token::Regexp::Match::         => q (m<...>x)),
		expect_element (PPI::Token::Regexp::Substitute::    => q (s (...) (...))),
		expect_element (PPI::Token::Regexp::Transliterate:: => q (tr (...) (...))),
		expect_element (PPI::Token::Regexp::Transliterate:: => q (y (...) (...))),
	);

had_no_warnings;
done_testing;

