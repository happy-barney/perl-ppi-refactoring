
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_statement;

my $token     = PPI::Token::Label::->new ('foo :');
my $statement = PPI::Statement::->new;
my $package   = PPI::Statement::Package::->new;

it_behaves_like_classification "it should accept instance of PPI::Statement"
	=> element => $statement
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept instance of PPI::Statement subclass"
	=> element => $package
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject token"
	=> element => $token
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject empty element (PPI returned empty string)"
	=> element => ''
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject class name itself"
	=> element => PPI::Statement::
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

