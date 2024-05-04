
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_transformation { &elements_wrap };

package Test::RHS {
	use parent qw (PPI::Node);
}

assume_transformation q (should insert elements after current element)
	=> document     => q (1 + 2 - 3)
	=> where        => where { it_is_token_number q (2) }
	=> arguments    => sub { current, [ current, next_siblings ], Test::RHS:: }
	=> expect       => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Number::     => q (1)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (+)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (Test::RHS:: => (
				expect_element (PPI::Token::Number::     => q (2)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Operator::   => q (-)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Number::     => q (3)),
			)),
		)),
	))
	=> returns      => [
		expect_element (Test::RHS:: => (
			expect_element (PPI::Token::Number::     => q (2)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (-)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (3)),
		))
	]
	;

assume_transformation q (should use provided instance)
	=> document     => q (1 + 2 - 3)
	=> where        => where { it_is_token_number q (2) }
	=> arguments    => sub {
		my $block = build_block (
			build_token_whitespace (q ( )),
			build_token_word (q (foo)),
			build_token_whitespace (q ( )),
		);

		return (current, [ current, next_siblings ], $block);
	}
	=> expect       => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Number::     => q (1)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (+)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Structure::Block::  => (
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Word::       => q (foo)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Number::     => q (2)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Operator::   => q (-)),
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Number::     => q (3)),
			)),
		)),
	))
	=> returns      => [
		expect_element (PPI::Structure::Block:: => (
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (2)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Operator::   => q (-)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Number::     => q (3)),
		))
	]
	;

assume_transformation q (should insert element before effective element)
	=> document     => q (package Foo;)
	=> where        => where { it_is_package_declaration }
	=> arguments    => sub {
		return (
			last_child,
			[
				build_token_whitespace (q ( )),
				build_token_word (q (foo)),
				last_child,
			],
			build_block,
		);
	}
	=> expect       => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement::Package:: => (
			expect_element (PPI::Token::Word::       => q (package)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (Foo)),
			expect_element (PPI::Structure::Block::  => (
				expect_element (PPI::Token::Whitespace:: => q ( )),
				expect_element (PPI::Token::Word::       => q (foo)),
				expect_element (PPI::Token::Structure::  => q (;)),
			)),
		)),
	))
	=> returns      => [
		expect_element (PPI::Structure::Block:: => (
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Word::       => q (foo)),
			expect_element (PPI::Token::Structure::  => q (;)),
		))
	]
	;

had_no_warnings;
done_testing;

