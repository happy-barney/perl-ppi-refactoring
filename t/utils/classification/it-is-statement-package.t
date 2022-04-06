
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_statement_package;

my $token     = PPI::Token::Label::->new ('foo :');
my $statement = PPI::Statement::->new;
my $package   = element_create (
	PPI::Statement::Package::,
	create_token_word ('package'),
	create_token_word ('Foo::Bar'),
);

it_behaves_like_classification "it should accept instance of PPI::Statement::Package"
	=> element => $package
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept instance of PPI::Statement::Package matching namespace condition"
	=> element => $package
	=> with    => [ { namespace => 'Foo::Bar' } ]
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject PPI::Statement::Package instance not matching namespace condition"
	=> element => $package
	=> with    => [ { namespace => 'Foo' } ]
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject instance of PPI::Statement"
	=> element => $statement
	=> expect  => expect_ppi_false
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

