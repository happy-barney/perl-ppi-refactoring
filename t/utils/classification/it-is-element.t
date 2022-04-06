
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_element;

my $element = PPI::Token::Word::->new ('foo');

it_behaves_like_classification "it should accept instance of PPI::Element"
	=> element => do { bless {}, PPI::Element:: }
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept instance of PPI::Element child"
	=> element => $element
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject empty element (PPI returned empty string)"
	=> element => ''
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject class name itself"
	=> element => PPI::Element::
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

