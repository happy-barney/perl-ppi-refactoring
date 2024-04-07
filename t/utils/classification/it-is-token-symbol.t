
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_symbol @_ };
arrange_document       { q ( $a; $a[0]; $a{1}; @a; %a ) };

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
		expect_element (PPI::Token::Symbol:: => q ($a)), # $a[0]
		expect_element (PPI::Token::Symbol:: => q (@a)), # @a
	);

had_no_warnings;
done_testing;

