
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_token_label;

my $word  = PPI::Token::Word::->new ('foo');
my $label = PPI::Token::Label::->new ('foo :');

it_behaves_like_classification "it should accept instance of PPI::Token::Label"
	=> element => $label
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject other token"
	=> element => $word
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject empty element (PPI returned empty string)"
	=> element => ''
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject class name itself"
	=> element => PPI::Token::Label::
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

