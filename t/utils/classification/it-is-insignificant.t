
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_insignificant;

it_behaves_like_classification "it should accept Token::Whitespace"
	=> element => PPI::Token::Whitespace->new ('')
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept Token::Pod"
	=> element => PPI::Token::Pod->new ('')
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept Token::Comment"
	=> element => PPI::Token::Comment->new ('')
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject significant element"
	=> element => PPI::Token::Word->new ('foo')
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

