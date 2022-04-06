
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_token_new_line;

my $space      = PPI::Token::Whitespace::->new (" ");
my $whitespace = PPI::Token::Whitespace::->new ("\n ");
my $newline    = PPI::Token::Whitespace::->new ("\n");

it_behaves_like_classification "it should accept Token::Whitespace containing newline"
	=> element => $newline
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject Token::Whitespace containing non-newline"
	=> element => $space
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject Token::Whitespace containing also non-newline"
	=> element => $whitespace
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject empty element (PPI returned empty string)"
	=> element => ''
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject class name itself"
	=> element => PPI::Token::Whitespace::
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

