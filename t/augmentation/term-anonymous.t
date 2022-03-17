
use require::relative "test-helper-augmentation.pl";

note <<'';
	Augmentation::Term::Anonymous wraps any anonymous data structure

plan tests => 6;

testing_augmentation 'PPIx::Augment::Augmentation::Term::Anonymous';

behaves_like_augmentation "PPIx::Augment::Augmentation::Term::Anonymous"
	=> document         => \ '$foo = []'
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol' => '$foo'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Operator', '='),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Structure::Constructor'),
		)),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol' => '$foo'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Operator', '='),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPIx::Augment::Expression::Term::Anonymous::Arrayref' => (
				expect_element ('PPI::Structure::Constructor'),
			)),
		)),
	))
	;

check_ppi "it should augment anonymous arrayref"
	=> document     => my $x = augmented_document (\ "my $foo = [ 1 ];")
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Term::Anonymous' }
	=> expect       => expect_element ('PPIx::Augment::Expression::Term::Anonymous::Arrayref' => (
		expect_element ('PPI::Structure::Constructor', '[ 1 ]'),
	))
	;

check_ppi "it should augment anonymous hashref"
	=> document     => my $x = augmented_document (\ "my $foo = { ... };")
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Term::Anonymous' }
	=> expect       => expect_element ('PPIx::Augment::Expression::Term::Anonymous::Hashref' => (
		expect_element ('PPI::Structure::Constructor', '{ ... }'),
	))
	;

check_ppi "it should augment anonymous sub"
	=> document     => my $x = augmented_document (\ "my $foo = sub { ... };")
	=> where_first  => where { it_is 'PPIx::Augment::Expression::Term::Anonymous' }
	=> expect       => expect_element ('PPIx::Augment::Expression::Term::Anonymous::Coderef' => (
		expect_element ('PPI::Token::Word', 'sub'),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Structure::Block', '{ ... }'),
	))
	;

had_no_warnings;

done_testing;
