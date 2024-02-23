
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

note <<'';
    As of v1.277 PPI recognizes last method / function called without parentheses
    in then clause of ternary expression as label.

use PPIx::Augment::Augmentation::Repair::PPI::Ternary_Operator_Colon;

testing_augmentation { PPIx::Augment::Augmentation::Repair::PPI::Ternary_Operator_Colon:: };

assume_augmentation q (should fix function call / glob)
	=> document         => q ($foo ? foo : bar)
	=> expect_parsed    => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Symbol::     => q ($foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (?)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Label::      => q (foo :)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	))
	=> expect_augmented => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Symbol::     => q ($foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (?)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (:)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	));

assume_augmentation q (should fix method call)
	=> document         => q ($foo ? FOO->foo : BAR->bar)
	=> expect_before    => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Symbol::     => q ($foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (?)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (FOO)),
			expect_element (PPI::Token::Operator::   => q (->)),
			expect_element (PPI::Token::Label::      => q (foo :)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (BAR)),
			expect_element (PPI::Token::Operator::   => q (->)),
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	))
	=> expect_augmented => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Symbol::     => q ($foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (?)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (FOO)),
			expect_element (PPI::Token::Operator::   => q (->)),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (:)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (BAR)),
			expect_element (PPI::Token::Operator::   => q (->)),
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	));

assume_augmentation q (fix shouldn't generate zero-length whitespace)
	=> document         => q ($foo ? foo: bar)
	=> expect_before    => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Symbol::     => q ($foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (?)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Label::      => q (foo:)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	))
	=> expect_augmented => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Symbol::     => q ($foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (?)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Operator::   => q (:)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	));

had_no_warnings;
done_testing;
