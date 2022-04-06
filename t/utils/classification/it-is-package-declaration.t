
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_package_declaration;

my $token     = PPI::Token::Label::->new ('foo :');
my $statement = PPI::Statement::->new;
my $declaration  = document ("package Foo;")->child (0)->clone;
my $with_version = document ("package Foo v1.0.0;")->child (0)->clone;
my $definition   = document ("package Foo v1.0.0 { }")->child (0)->clone;

it_behaves_like_classification "it should accept package declaration"
	=> element => $declaration
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept package declaration with version"
	=> element => $with_version
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject package definition"
	=> element => $definition
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should accept package declaration matching namespace condition"
	=> element => $declaration
	=> with    => [ { namespace => 'Foo' } ]
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject package declaration not matching namespace condition"
	=> element => $declaration
	=> with    => [ { namespace => 'Bar' } ]
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
	=> element => PPI::Statement::Package::
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

