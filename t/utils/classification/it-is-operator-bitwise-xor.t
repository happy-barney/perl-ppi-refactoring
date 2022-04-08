
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_operator_bitwise_xor;

it_behaves_like_classification "it should accept operator instance with '^' content"
	=> element => PPI::Token::Operator::->new ('^')
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject other operator instance"
	=> element => PPI::Token::Operator::->new ('=>')
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should check content before evaluating additional conditions"
	=> element => PPI::Token::Operator::->new ('=>')
	=> with    => [ sub { fail "should not be called" } ]
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

