
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_ppi q (should return instance of PPI::Token::Cast)
	=> got    => build_token_cast (q ($))
	=> expect => expect_element (PPI::Token::Cast:: => q ($))
	;

assume_ppi q (should return 'undef' when content isn't defined)
	=> got    => build_token_cast (undef)
	=> expect => undef
	;

had_no_warnings;
done_testing;

