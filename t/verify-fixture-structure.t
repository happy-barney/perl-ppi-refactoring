
use v5.14;
use warnings;

use Test::Load::Helper;

assume_ppi q (should parse fixture path 'simple-document.pl')
	=> document => fixture (q (simple-document.pl))
	=> expect   => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Number::     => q (1)),
			expect_element (PPI::Token::Structure::  => q (;)),
		)),
		expect_element (PPI::Token::Whitespace:: => qq (\n)),
	));

assume_ppi q (should parse fixture 'ternary-and-heredoc.pl')
	=> document => fixture (q (ternary-and-heredoc.pl))
	=> expect   => expect_element (PPI::Document::          => (
		expect_element (PPI::Token::Whitespace::            => qq (\n)),

		expect_element (PPI::Statement::Package::           => (
			expect_element (PPI::Token::Word::              => q (package)),
			expect_element (PPI::Token::Whitespace::        => q ( )),
			expect_element (PPI::Token::Word::              => q (Foo)),
			expect_element (PPI::Token::Structure::         => q (;)),
		)),
		expect_element (PPI::Token::Whitespace::            => qq (\n)),
		expect_element (PPI::Token::Whitespace::            => qq (\n)),

		expect_element (PPI::Statement::Sub::               => (
			expect_element (PPI::Token::Word::              => q (sub)),
			expect_element (PPI::Token::Whitespace::        => q ( )),
			expect_element (PPI::Token::Word::              => q (foo)),
			expect_element (PPI::Token::Whitespace::        => q ( )),
			expect_element (PPI::Token::Prototype::         => q (($bar))),
			expect_element (PPI::Token::Whitespace::        => q ( )),
			expect_element (PPI::Structure::Block::         => (
				expect_element (PPI::Token::Whitespace::    => ), #qq (\n)),
				expect_element (PPI::Token::Whitespace::    => ), #qq (\t)),
				expect_element (PPI::Statement::            => (
					expect_element (PPI::Token::Symbol::    => ), #q ($bar)),
					expect_element (PPI::Token::Whitespace::=> ), #q ( )),
					expect_element (PPI::Token::Operator::  => ), #q (?)),
					expect_element (PPI::Token::Whitespace::=> ), #q ( )),
					expect_element (PPI::Token::HereDoc::   => ), #q (>>'TRUE')), #, { heredoc => qq (true\n) }),
					expect_element (PPI::Token::Whitespace::=> ), #q ( )),
					expect_element (PPI::Token::Operator::  => ), #q (:)),
					expect_element (PPI::Token::Whitespace::=> ), #q ( )),
					expect_element (PPI::Token::HereDoc::   => ), #q (>>'FALSE')), #, { heredoc => qq (false\n) }),
					expect_element (PPI::Token::Structure:: => ), #q (;)),
				)),
				expect_element (PPI::Token::Whitespace::    => ), #qq (\n)),
			)),
		)),
		expect_element (PPI::Token::Whitespace::            => ), #qq (\n)),
	));

had_no_warnings;
done_testing;
