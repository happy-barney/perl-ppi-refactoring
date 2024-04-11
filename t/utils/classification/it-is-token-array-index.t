
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_array_index @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
$#foo;
$#$bar;
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Token::ArrayIndex)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::ArrayIndex:: => q ($#foo), { line_number => 1 }),
	);

had_no_warnings;
done_testing;

