
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { & it_is_token_symbol };
arrange_document       { <<'END_OF_DOCUMENT' };
$a;
$a[0];
$a{1};
@a;
%a
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::Symbol::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Symbol:: => q ($a)),
		expect_element (PPI::Token::Symbol:: => q ($a)),
		expect_element (PPI::Token::Symbol:: => q ($a)),
		expect_element (PPI::Token::Symbol:: => q (@a)),
		expect_element (PPI::Token::Symbol:: => q (%a)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ { symbol => q (@a) } ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Symbol:: => q ($a), { line_number => 2 }),
		expect_element (PPI::Token::Symbol:: => q (@a), { line_number => 4 }),
	);

had_no_warnings;
done_testing;

