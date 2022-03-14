
use require::relative "test-helper-augmentation.pl";

note <<'';
	Cast block is an expression like ${ ... }
	Augmentation::Cast_Block joins it into single PPIx::Augment element

not 1 and plan tests => 3;

testing_augmentation 'PPIx::Augment::Augmentation::Term::Dereference';

behaves_like_augmentation "PPIx::Augment::Augmentation::Term::Dereference"
	=> document         => \ '$foo = $ { bar } ;'
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol' => '$foo'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Operator', '='),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Cast', '$'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Structure::Block'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol' => '$foo'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Operator', '='),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Dereference' => (
				expect_element ('PPI::Token::Cast', '$'),
				expect_element ('PPI::Token::Whitespace'),
				expect_element ('PPI::Structure::Block'),
			)),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	;

check_ppi 'it should augment expression $$bar'
	=> document     => augmented_document (\ '$$bar')
	=> expect       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPIx::Augment::Expression::Term::Dereference' => (
				expect_element ('PPI::Token::Cast', '$'),
				expect_element ('PPIx::Augment::Expression::Term::Variable' => (
					expect_element ('PPI::Token::Symbol', '$bar'),
				)),
			)),
		)),
	)),
	;

check_ppi 'it should augment expression $$$bar (right-to-left)'
	=> document     => augmented_document (\ '$$$bar')
	=> expect       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPIx::Augment::Expression::Term::Dereference' => (
				expect_element ('PPI::Token::Cast', '$'),
				expect_element ('PPIx::Augment::Expression::Term::Dereference' => (
					expect_element ('PPI::Token::Cast', '$'),
					expect_element ('PPIx::Augment::Expression::Term::Variable' => (
						expect_element ('PPI::Token::Symbol', '$bar'),
					)),
				)),
			)),
		)),
	)),
	;

not 1 and check_ppi "it should augment expression \$ { ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = $ { ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('$ { ... }')
	;

not 1 and check_ppi "it should augment expression \@{ ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = @{ ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('@{ ... }')
	;

not 1 and check_ppi "it should augment expression \%{ ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = %{ ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('%{ ... }')
	;

done_testing;
