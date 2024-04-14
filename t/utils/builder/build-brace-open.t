
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_builder { &build_brace_open };

assume_builder q (should build operator token with '{')
	=> expect  => expect_element (PPI::Token::Structure:: => q ({))
	;

had_no_warnings;
done_testing;
