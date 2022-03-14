
use require::relative "test-helper-augmentation.pl";

note <<'';
	do BLOCK is treated as single term
	Augmentation Term::Do_Block wraps these two significant nodes into
	single element.

plan tests => 4;

testing_augmentation 'PPIx::Augment::Augmentation::Term::Do_Block';

behaves_like_augmentation "it should wrap <do {}> into single element"
	=> document         => \ 'do { ... };'
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'do'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Structure::Block'),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPIx::Augment::Expression::Term::Do::Block' => (
				expect_element ('PPI::Token::Word' => 'do'),
				expect_element ('PPI::Token::Whitespace'),
				expect_element ('PPI::Structure::Block'),
			)),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	;

behaves_like_augmentation "it should wrap nested do statements"
	=> document         => \ 'do { do { ... } };'
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'do'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Structure::Block' => (
				expect_element ('PPI::Token::Whitespace'),
				expect_element ('PPI::Statement' => (
					expect_element ('PPI::Token::Word' => 'do'),
					expect_element ('PPI::Token::Whitespace'),
					expect_element ('PPI::Structure::Block'),
				)),
				expect_element ('PPI::Token::Whitespace'),
			)),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPIx::Augment::Expression::Term::Do::Block' => (
				expect_element ('PPI::Token::Word' => 'do'),
				expect_element ('PPI::Token::Whitespace'),
				expect_element ('PPI::Structure::Block' => (
					expect_element ('PPI::Token::Whitespace'),
					expect_element ('PPI::Statement' => (
						expect_element ('PPIx::Augment::Expression::Term::Do::Block' => (
							expect_element ('PPI::Token::Word' => 'do'),
							expect_element ('PPI::Token::Whitespace'),
							expect_element ('PPI::Structure::Block'),
						)),
					)),
					expect_element ('PPI::Token::Whitespace'),
				)),
			)),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	;


had_no_warnings;

done_testing;
