
use v5.14;
use warnings;

use require::relative 'test-helper.pl';

check_ppi "should parse fixture path 'simple-document.pl'"
	=> document => fixture_path ('simple-document.pl')
	=> expect   => expect_element ('PPIx::Augment::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Number'     => '1'),
			expect_element ('PPI::Token::Structure'  => ';'),
		)),
		expect_element ('PPI::Token::Whitespace' => "\n"),
	));

check_ppi "should parse fixture 'simple-document.pl'"
	=> document => fixture ('simple-document.pl')
	=> expect   => expect_element ('PPIx::Augment::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Number'     => '1'),
			expect_element ('PPI::Token::Structure'  => ';'),
		)),
		expect_element ('PPI::Token::Whitespace' => "\n"),
	));

check_ppi "should parse evaluate where clause"
	=> document => '1;2;4'
	=> where    => sub { $_[1]->isa ('PPI::Token::Number') }
	=> expect   => [
		expect_element ('PPI::Token::Number' => '1'),
		expect_element ('PPI::Token::Number' => '2'),
		expect_element ('PPI::Token::Number' => '4'),
	];

check_ppi "should parse evaluate first clause"
	=> document => '1;2;4'
	=> first    => sub { $_[1]->isa ('PPI::Token::Number') }
	=> expect   => [
		expect_element ('PPI::Token::Number' => '1')
	];

had_no_warnings;

done_testing;
