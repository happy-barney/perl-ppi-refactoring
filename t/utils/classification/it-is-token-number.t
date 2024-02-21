
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

had_no_warnings;
done_testing;

