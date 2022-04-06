
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should not build a token from undef content"
	=> got    => [ create_token_operator undef ]
	=> expect => []
	;

it "should not build a token from empty string"
	=> got    => [ create_token_operator '' ]
	=> expect => []
	;

it "should build token operator"
	=> got    => [ create_token_operator '=>' ]
	=> expect => [ expect_element 'PPI::Token::Operator' => '=>' ]
	;

it "should build token operator even with non-operator content"
	=> got    => [ create_token_operator '0-foo' ]
	=> expect => [ expect_element 'PPI::Token::Operator' => '0-foo' ]
	;

had_no_warnings;

done_testing;
