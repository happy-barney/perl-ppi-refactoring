
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_cast @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
@$foo;
%{ $foo };
$foo->$*;
$foo->$#*;
$#$foo;
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Token::Cast)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Cast:: => q (@)),
		expect_element (PPI::Token::Cast:: => q (%)),
		expect_element (PPI::Token::Cast:: => q ($*)),
		expect_element (PPI::Token::Cast:: => q ($#*)),
		expect_element (PPI::Token::Cast:: => q ($#)),
	);

had_no_warnings;
done_testing;

