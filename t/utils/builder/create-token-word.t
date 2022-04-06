
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should not build a token from undef content"
	=> got    => [ create_token_word undef ]
	=> expect => []
	;

it "should not build a token from empty string"
	=> got    => [ create_token_word '' ]
	=> expect => []
	;

it "should build token word"
	=> got    => [ create_token_word 'foo' ]
	=> expect => [ expect_element 'PPI::Token::Word' => 'foo' ]
	;

it "should build token word even with non-word content"
	=> got    => [ create_token_word '0-foo' ]
	=> expect => [ expect_element 'PPI::Token::Word' => '0-foo' ]
	;

had_no_warnings;

done_testing;
