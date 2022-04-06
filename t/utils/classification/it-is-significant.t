
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_significant;

it_behaves_like_classification "it should reject insignificant element"
	=> element => PPI::Token::Whitespace->new ('')
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should accept significant element"
	=> element => PPI::Token::Word->new ('foo')
	=> expect  => expect_ppi_true
	;

had_no_warnings;

done_testing;

