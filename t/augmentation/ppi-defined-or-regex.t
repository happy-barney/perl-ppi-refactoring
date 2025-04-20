
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Augment::Augmentation::PPI::Defined_Or_Regex;

testing_augmentation { PPIx::Augment::Augmentation::PPI::Defined_Or_Regex:: };

assume_augmentation q (should fix 'ref // 1')
	=> document        => q (ref // 1)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Word::       => q (ref)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (//)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (1)),
		)),
	)
	=> expect_analyze => [
		expect_element (PPI::Token::Operator::   => q (//)),
	]
	=> expect_augment => expect_true,
	=> expect_result  => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Word::          => q (ref)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Regexp::Match:: => q (//)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Number::        => q (1)),
		)),
	)
	;

assume_augmentation q (should fix 'foo // 1')
	=> document        => q (foo // 1)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (//)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (1)),
		)),
	)
	=> expect_augment => expect_true,
	=> expect_result  => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Word::          => q (foo)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Regexp::Match:: => q (//)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Number::        => q (1)),
		)),
	);

assume_augmentation q (should not fix '$obj->foo // 1')
	=> document        => q ($obj->foo // 1)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Symbol::     => q ($obj)),
			expect_element (PPI::Token::Operator::   => q (->)),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (//)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (1)),
		)),
	)
	=> expect_augment => expect_false,
	=> expect_result  => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Symbol::     => q ($obj)),
			expect_element (PPI::Token::Operator::   => q (->)),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (//)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (1)),
		)),
	);

had_no_warnings;
done_testing;

