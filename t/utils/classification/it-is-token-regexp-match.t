
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_regexp_match @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
ref // 0;
//;
qr (...);
m<...>x;
s (...) (...);
tr (...) (...);
y (...) (...);
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Regexp::Match)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Regexp::Match:: => q (//), { line_number => 2 }),
		expect_element (PPI::Token::Regexp::Match:: => q (m<...>x)),
	);

had_no_warnings;
done_testing;

