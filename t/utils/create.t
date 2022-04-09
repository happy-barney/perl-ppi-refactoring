
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

plan tests => 5;

it "should build operator token"
	=> got    => create_token_operator '->'
	=> expect => expect_element ('PPI::Token::Operator' => '->')
	;

it "should build whitespace token"
	=> got    => create_token_whitespace '   '
	=> expect => expect_element ('PPI::Token::Whitespace' => '   ')
	;

it "should build word token"
	=> got    => create_token_word 'do'
	=> expect => expect_element ('PPI::Token::Word' => 'do')
	;

it "shouldn't build empty whitespace token"
	=> got    => scalar create_token_whitespace ''
	=> expect => undef
	;

had_no_warnings;

done_testing;
