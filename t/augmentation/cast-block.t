
use require::relative "../test-helper.pl";

use PPIx::Augment::Augmentation::Cast_Block;

note <<''
	Cast block is an expression like ${ ... }
	Augmentation::Cast_Block joins it into single PPIx::Augment element

	;

behaves_like_augmentation "PPIx::Augment::Augmentation::Cast_Block"
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
			expect_element ('PPIx::Augment::Expression::Cast_Block' => (
				expect_element ('PPI::Token::Cast', '$'),
				expect_element ('PPI::Token::Whitespace'),
				expect_element ('PPI::Structure::Block'),
			)),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Structure', ';'),
		)),
	))
	;

check_ppi "it should augment expression \${ ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = ${ ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('${ ... }')
	;

check_ppi "it should augment expression \$ { ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = $ { ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('$ { ... }')
	;

check_ppi "it should augment expression \@{ ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = @{ ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('@{ ... }')
	;

check_ppi "it should augment expression \%{ ... }"
	=> document     => my $x = augmented_document (\ 'my $foo = %{ ... }')
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Cast_Block' }
	=> expect       => expect_content ('%{ ... }')
	;

done_testing;
