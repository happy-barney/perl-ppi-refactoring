
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_operator;

it_behaves_like_classification "it should accept instance of operator '->'"
	=> element => PPI::Token::Operator::->new ('->')
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept instance of operator '=>'"
	=> element => PPI::Token::Operator::->new ('=>')
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should check operator operator class before additional condition"
	=> element => PPI::Statement::->new,
	=> with    => [ sub { fail "should not be called" } ]
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

