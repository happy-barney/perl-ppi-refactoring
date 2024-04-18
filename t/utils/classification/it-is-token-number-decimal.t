
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { &it_is_token_number_decimal };
arrange_document       { <<'END_OF_DOCUMENT' };
0;
-1;
-1.1;
0b1;
0.2;
0x3;
04;
v0.5;
END_OF_DOCUMENT

assume_ppi q (should match only decimal integer numbers)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::          => q  (0)),
		expect_element (PPI::Token::Number::          => q  (-1)),
	);

had_no_warnings;
done_testing;

