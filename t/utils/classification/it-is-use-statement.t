
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is_use_statement;;

my $use_foo   = document ("use Foo")->child (0)->clone;
my $use_bar   = document ("use Bar")->child (0)->clone;
my $no_foo    = document ("no Foo")->child (0)->clone;

it_behaves_like_classification "it should reject no statement"
	=> element => $no_foo
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should accept use statement"
	=> element => $use_foo
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept use statement with matching module name"
	=> element => $use_foo
	=> with    => [{ module => 'Foo' }]
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject use statement with non-matching module name"
	=> element => $use_bar
	=> with    => [{ module => 'Foo' }]
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

