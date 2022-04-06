
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should not build a token from undef content"
	=> got    => [ create_token_number_octal undef ]
	=> expect => []
	;

it "should not build a token from empty string"
	=> got    => [ create_token_number_octal '' ]
	=> expect => []
	;

it "should build token Number::Octal"
	=> got    => [ create_token_number_octal '0123' ]
	=> expect => [ expect_element 'PPI::Token::Number::Octal' => '0123' ]
	;

it "should build token Number::Octal even with non-octal content"
	=> got    => [ create_token_number_octal '0-foo' ]
	=> expect => [ expect_element 'PPI::Token::Number::Octal' => '0-foo' ]
	;

had_no_warnings;

done_testing;
