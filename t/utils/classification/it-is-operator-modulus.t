
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_operator_modulus @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
1 % 2
END_OF_DOCUMENT

assume_ppi q (should match operator '%')
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Operator:: => q (%)),
	);

had_no_warnings;
done_testing;

