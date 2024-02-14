
use v5.14;
use warnings;

use require::relative q (../test-helper-augmentation.pl);

use PPIx::Augment::Augmentation::Context_Package;

testing_ppix_augmentation { PPIx::Augment::Augmentation::Context_Package:: };

assume_ppix_augment_knows_augmentation;

assume_ppix_augmentation q (should wrap package statement)
	=> document         => q (package foo { bar })
	=> expect_parsed    => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement::Package:: => (
			expect_element (PPI::Token::Word::       => q (package)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Structure::Block::  => (
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Statement::         => (
					expect_element (PPI::Token::Word::       => q (bar)),
				)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
			)),
		)),
	))
	=> expect_augmented => expect_element (PPI::Document:: => (
		expect_element (PPIx::Augment::Context::Package:: => (
			expect_element (PPI::Statement::Package:: => (
				expect_element (PPI::Token::Word::       => q (package)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Word::       => q (foo)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Structure::Block::  => (
					expect_element (PPI::Token::Whitespace:: => q ( )),
					expect_element (PPI::Statement::         => (
						expect_element (PPI::Token::Word::       => q (bar)),
					)),
					expect_element (PPI::Token::Whitespace:: => q ( )),
				)),
			)),
		)),
	));

assume_ppix_augmentation q (should wrap package declaration and subsequent siblings)
	=> document         => q (package foo; foo; package bar; bar),
	=> expect_parsed    => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement::Package:: => (
			expect_element (PPI::Token::Word::       => q (package)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Structure::  => q (;)),
		)),
		expect_element (PPI::Token::Whitespace:: => q ( )),

		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Structure::  => q (;)),
		)),
		expect_element (PPI::Token::Whitespace:: => q ( )),

		expect_element (PPI::Statement::Package:: => (
			expect_element (PPI::Token::Word::       => q (package)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (bar)),
			expect_element (PPI::Token::Structure::  => q (;)),
		)),
		expect_element (PPI::Token::Whitespace:: => q ( )),

		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Word::       => q (bar)),
		)),
	))
	=> expect_augmented => expect_element (PPI::Document:: => (
		expect_element (PPIx::Augment::Context::Package:: => (
			expect_element (PPI::Statement::Package:: => (
				expect_element (PPI::Token::Word::       => q (package)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Word::       => q (foo)),
				expect_element (PPI::Token::Structure::  => q (;)),
			)),
			expect_element (PPI::Token::Whitespace:: => q ( )),

			expect_element (PPI::Statement:: => (
				expect_element (PPI::Token::Word::       => q (foo)),
				expect_element (PPI::Token::Structure::  => q (;)),
			)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
		)),

		expect_element (PPIx::Augment::Context::Package:: => (
			expect_element (PPI::Statement::Package:: => (
				expect_element (PPI::Token::Word::       => q (package)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Word::       => q (bar)),
				expect_element (PPI::Token::Structure::  => q (;)),
			)),
			expect_element (PPI::Token::Whitespace:: => q ( )),

			expect_element (PPI::Statement:: => (
				expect_element (PPI::Token::Word::       => q (bar)),
			)),
		)),
	));

had_no_warnings;
done_testing;
