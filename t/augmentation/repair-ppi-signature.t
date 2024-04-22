
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Augment::Augmentation::Repair::PPI::Signature;

testing_augmentation { PPIx::Augment::Augmentation::Repair::PPI::Signature:: };

assume_augmentation q (should fix method signature)
	=> document        => q (sub foo ($self);)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::Sub::           => (
			expect_element (PPI::Token::Word::          => q (sub)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Word::          => q (foo)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Prototype::     => q (($self))),
			expect_element (PPI::Token::Structure::     => q (;)),
		)),
	)
	=> expect_result  => expect_document (
		expect_element (PPI::Statement::Sub::           => (
			expect_element (PPI::Token::Word::          => q (sub)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPI::Token::Word::          => q (foo)),
			expect_element (PPI::Token::Whitespace::    => q ( )),
			expect_element (PPIx::Augment::Structure::Signature::V520:: => (
				expect_element (PPI::Statement::Expression::            => (
					expect_element (PPI::Token::Symbol::                => q ($self)),
				)),
			)),
			expect_element (PPI::Token::Structure::     => q (;)),
		)),
	);

had_no_warnings;
done_testing;

