
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

my $document = <<'END_OF_DOCUMENT';
0
0b1
0.2
0x3
04
v0.5
END_OF_DOCUMENT

assume_ppi q (it_is_token_number () should match all numbers)
	=> document => $document
	=> where    => sub { it_is_token_number ($_[1]) }
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Number::          => q  (0)),
		expect_element (PPI::Token::Number::Binary::  => q  (0b1)),
		expect_element (PPI::Token::Number::Float::   => q  (0.2)),
		expect_element (PPI::Token::Number::Hex::     => q  (0x3)),
		expect_element (PPI::Token::Number::Octal::   => q  (04)),
		expect_element (PPI::Token::Number::Version:: => q  (v0.5)),
	);

testing_classification { \& it_is_token_number };

assert_classification q (should accept instance of PPI::Token::Number)
	=> element => PPI::Token::Number::->new (q (1))
	=> expect  => expect_ppi_true
	;

assert_classification q (should accept instance of PPI::Token::Number::Hex)
	=> element => PPI::Token::Number::Hex::->new (q (0x1))
	=> expect  => expect_ppi_true
	;

assert_classification q (should accept instance of PPI::Token::Number::Float)
	=> element => PPI::Token::Number::Float::->new (q (1.1))
	=> expect  => expect_ppi_true
	;

assert_classification q (should reject other token)
	=> element => PPI::Token::Label::->new (q (foo))
	=> expect  => expect_ppi_false
	;

assert_classification q (should reject empty element (PPI returned empty string))
	=> element => q ()
	=> expect  => expect_ppi_false
	;

assert_classification q (should reject no_element())
	=> element => no_element ()
	=> expect  => expect_ppi_false
	;

assert_classification q (should reject class name itself)
	=> element => PPI::Token::Number::
	=> expect  => expect_ppi_false
	;

had_no_warnings;
done_testing;

