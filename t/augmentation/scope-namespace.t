
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Augment::Augmentation::Scope::Namespace;

testing_ppix_augmentation { PPIx::Augment::Augmentation::Scope::Namespace:: };

arrange_document     { <<'END_OF_DOCUMENT' };
our $foo;

package Foo;
our $foo;

package Bar {
    our $foo;
}
END_OF_DOCUMENT

assume_augmentation q (should repair comments with leading/trailing whitespaces)
	=> expect_analyze => [
		expect_element (PPI::Token::::,    qq (#!perl\n)),
		expect_element (PPI::Token::Comment::,    qq (    # comment with indent\n)),
		expect_element (PPI::Token::Comment::,    qq (    # comment with indent\n)),
	]
	=> expect_augment => 3
	=> expect_result  => expect_element (PPI::Document::, (
		expect_element (PPI::Token::Comment::,    qq (#!perl)),
		expect_element (PPI::Token::Whitespace::, qq (\n)),
		expect_element (PPI::Token::Whitespace::, q  (    )),
		expect_element (PPI::Token::Comment::,    qq (# comment with indent)),
		expect_element (PPI::Token::Whitespace::, qq (\n)),

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
