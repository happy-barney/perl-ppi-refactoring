
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

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

subtest q (with classification) => sub {
	sub test_classification_is_statement {
		$_->isa (PPI::Statement::);
	}

	testing_classification { $_->isa (PPI::Token::Number::) };

	assume_ppi q (should recognize tested classification)
		=> document => q (1;2;4)
		=> expect   => expect_nodeset (
			expect_element (PPI::Token::Number:: => q (1)),
			expect_element (PPI::Token::Number:: => q (2)),
			expect_element (PPI::Token::Number:: => q (4)),
		);

	assume_ppi q (should favour implicit 'classification' over tested classification)
		=> document       => q (1;2;4)
		=> classification => sub { $_ =~ qr (^[24]$) }
		=> expect         => expect_nodeset (
			expect_element (PPI::Token::Number::    => q (2)),
			expect_element (PPI::Statement::        => q (4)),
			expect_element (PPI::Token::Number::    => q (4)),
		);

	assume_ppi q (should pass classification conditions)
		=> document       => q (1;2;4)
		=> classification => sub { $_ =~ shift }
		=> conditions     => [ qr (^;$) ]
		=> expect         => expect_nodeset (
			expect_element (PPI::Token::Structure:: => q (;)),
			expect_element (PPI::Token::Structure:: => q (;)),
		);

	assume_ppi q (should recognize (stringified) classification function)
		=> document       => q (1;2;4)
		=> classification => test_classification_is_statement
		=> conditions     => [ qr (^;$) ]
		=> expect         => expect_nodeset (
			expect_element (PPI::Statement:: => q (1;)),
			expect_element (PPI::Statement:: => q (2;)),
			expect_element (PPI::Statement:: => q (4)),
		);

	assume_ppi q (should favour implicit 'where' over tested classification)
		=> document       => q (1;2;4)
		=> where          => sub { $_[1]->isa (PPI::Token::Structure::) }
		=> expect         => expect_nodeset (
			expect_element (PPI::Token::Structure:: => q (;)),
			expect_element (PPI::Token::Structure:: => q (;)),
		);

	assume_ppi q (should favour implicit 'where' over 'classification')
		=> document       => q (1;2;4)
		=> where          => sub { $_[1]->isa (PPI::Token::Structure::) }
		=> classification => sub { $_ =~ qr ([24]) }
		=> expect         => expect_nodeset (
			expect_element (PPI::Token::Structure:: => q (;)),
			expect_element (PPI::Token::Structure:: => q (;)),
		);
};

had_no_warnings;
done_testing;
