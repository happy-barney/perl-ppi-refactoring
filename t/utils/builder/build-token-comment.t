
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_ppi q (should return instance of PPI::Token::Comment)
	=> got    => build_token_comment (q (# foo))
	=> expect => expect_element (PPI::Token::Comment:: => q (# foo))
	;

assume_ppi q (should return 'undef' when content doesn't start with '#')
	=> got    => build_token_comment (q (foo))
	=> expect => undef
	;

assume_ppi q (should return 'undef' when content isn't defined)
	=> got    => build_token_comment (undef)
	=> expect => undef
	;

had_no_warnings;
done_testing;

