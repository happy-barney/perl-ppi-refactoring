
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should not build a token from undef content"
	=> got    => [ create_token_whitespace undef ]
	=> expect => []
	;

it "should not build a token from empty string"
	=> got    => [ create_token_whitespace '' ]
	=> expect => []
	;

it "should build token whitespace"
	=> got    => [ create_token_whitespace '   ' ]
	=> expect => [ expect_element 'PPI::Token::Whitespace' => '   ' ]
	;

it "should build token whitespace even with non-whitespace content"
	=> got    => [ create_token_whitespace '0-foo' ]
	=> expect => [ expect_element 'PPI::Token::Whitespace' => '0-foo' ]
	;

had_no_warnings;

done_testing;
