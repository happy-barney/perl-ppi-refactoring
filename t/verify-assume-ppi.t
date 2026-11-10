
use v5.14;
use warnings;

use Test::Load::Helper;

subtest q (basic features) => sub {
	assume_ppi q (should parse fixture path 'simple-document.pl')
		=> document => fixture_path (q (simple-document.pl))
		=> expect   => expect_element (PPI::Document:: => (
			expect_element (PPI::Statement:: => (
				expect_element (PPI::Token::Number::     => q (1)),
				expect_element (PPI::Token::Structure::  => q (;)),
			)),
			expect_element (PPI::Token::Whitespace:: => qq (\n)),
		));

	assume_ppi q (should parse fixture 'simple-document.pl')
		=> document => fixture (q (simple-document.pl))
		=> expect   => expect_element (PPI::Document:: => (
			expect_element (PPI::Statement:: => (
				expect_element (PPI::Token::Number::     => q (1)),
				expect_element (PPI::Token::Structure::  => q (;)),
			)),
			expect_element (PPI::Token::Whitespace:: => qq (\n)),
		));

	assume_ppi q (should recognize 'where' clause)
		=> document => q (1;2;4)
		=> where    => sub { $_[1]->isa (PPI::Token::Number::) }
		=> expect   => expect_nodeset (
			expect_element (PPI::Token::Number:: => q (1)),
			expect_element (PPI::Token::Number:: => q (2)),
			expect_element (PPI::Token::Number:: => q (4)),
		);

	assume_ppi q (should recognize 'first' clause)
		=> document => q (1;2;4)
		=> first    => sub { $_[1]->isa (PPI::Token::Number::) }
		=> expect   => expect_nodeset (
			expect_element (PPI::Token::Number:: => q (1))
		);

	assume_ppi q (should evaluate 'invoke' clause)
		=> document => q (1;2;4)
		=> where    => sub { $_[1]->isa (PPI::Token::Number::) }
		=> invoke   => sub { $_[1]->set_content ($_[1]->content . q (0)) }
		=> expect   => expect_nodeset (
			expect_element (PPI::Token::Number:: => q (10)),
			expect_element (PPI::Token::Number:: => q (20)),
			expect_element (PPI::Token::Number:: => q (40)),
		);
};

had_no_warnings;
done_testing;
