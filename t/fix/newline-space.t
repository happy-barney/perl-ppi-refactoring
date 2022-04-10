
use v5.14;
use warnings;

use require::relative "../test-helper-augmentation.pl";

note <<'';
	As of current PPI (v1.272) multiple new-lines are not separate elements

#plan tests => 4;

local *ppix_augmentation
	= testing_ppix_augmentation 'PPIx::Augment::Fix::Newline_Spaces'
	;

my $document = <<'DOCUMENT';
	foo;


	bar;
DOCUMENT

behaves_like_ppix_augmentation "split whitespace with new-lines and tabs"
	=> document     => $document
	=> expect_ppi   => expect_element ('PPI::Document' => (
		#expect_element ("PPI::Token::Whitespace", "\t"),
		#expect_element ("PPI::Statement" => (
		#	expect_element ("PPI::Token::Word" => "foo"),
		#	expect_element ("PPI::Token::Structure", ";"),
		#)),
		#expect_element ("PPI::Token::Whitespace", "\n"),
		#expect_element ("PPI::Token::Whitespace", "\n"),
		#expect_element ("PPI::Token::Whitespace", "\n\t"),
		#expect_element ("PPI::Statement" => (
		#	expect_element ("PPI::Token::Word" => "bar"),
		#	expect_element ("PPI::Token::Structure", ";"),
		#)),
		#expect_element ("PPI::Token::Whitespace", "\n"),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ("PPI::Token::Whitespace", "\t"),
		expect_element ("PPI::Statement" => (
			expect_element ("PPI::Token::Word" => "foo"),
			expect_element ("PPI::Token::Structure", ";"),
		)),
		expect_element ("PPI::Token::Whitespace", "\n"),
		expect_element ("PPI::Token::Whitespace", "\n"),
		expect_element ("PPI::Token::Whitespace", "\n"),
		expect_element ("PPI::Token::Whitespace", "\t"),
		expect_element ("PPI::Statement" => (
			expect_element ("PPI::Token::Word" => "bar"),
			expect_element ("PPI::Token::Structure", ";"),
		)),
		expect_element ("PPI::Token::Whitespace", "\n"),
	));

ppix_augment_should_execute_ppix_augmentation;

had_no_warnings;

done_testing;
