
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_quote_literal @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
q  (1 2 3);
qq (2 3 4);
'3 4 5';
"4 5 6";
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Quote::Literal::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Quote::Literal:: => q (q  (1 2 3))),
	);

had_no_warnings;
done_testing;

