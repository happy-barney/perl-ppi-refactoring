
use v5.14;
use warnings;

use require::relative "test-helper-augmentation.pl";

note <<'';
	Augmentation Term::Literal wraps literal values

plan tests => 3;

testing_augmentation 'PPIx::Augment::Augmentation::Term::Literal';

behaves_like_augmentation "literal values should be wrapped by Term::Literal element"
	=> document         => \ '1_024 2.2 0x3 0b0_0011_1100 0o0777 "foo" q[bar]'
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Number' => '1_024'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Number::Float' => '2.2'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Number::Hex' => '0x3'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Number::Binary' => '0b0_0011_1100'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Number' => '0'),
			expect_element ('PPI::Token::Word' => 'o0777'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Quote::Double' => '"foo"'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Quote::Literal' => 'q[bar]'),
		)),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Number' => '1_024'),
			),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Number::Float' => '2.2'),
			),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Number::Hex' => '0x3'),
			),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Number::Binary' => '0b0_0011_1100'),
			),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Number::Octal' => '0o0777'),
			),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Quote::Double' => '"foo"'),
			),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Literal',
				expect_element ('PPI::Token::Quote::Literal' => 'q[bar]'),
			),
		)),
	))
	;

had_no_warnings;

done_testing;
