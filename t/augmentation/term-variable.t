
use require::relative "test-helper-augmentation.pl";

note <<'';
	Augmentation::Term::Variable should wrap any kind of variable reference
	(including '*', excluding dereferences and subroutines)

plan tests => 6;

testing_augmentation 'PPIx::Augment::Augmentation::Term::Variable';

behaves_like_augmentation "it should wrap variables into marker element"
	=> document         => \ '$foo'
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol' => '$foo'),
		)),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPIx::Augment::Expression::Term::Variable' => (
				expect_element ('PPI::Token::Symbol' => '$foo'),
			)),
		)),
	))
	;

sub check_augmented_variable {
	my ($expression) = @_;

	check_ppi "it should augment '$expression'"
		=> document     => my $x = augmented_document (\ "my $expression = 1;")
		=> where_first  => where { it_is 'PPIx::Augment::Expression::Term::Variable' }
		=> expect       => expect_content ($expression)
		;
}

sub subtest_variables {
	my ($title, $sigil) = @_;

	subtest $title => sub {
		check_augmented_variable "${sigil}foo";
		check_augmented_variable "${sigil} foo";
		check_augmented_variable "${sigil}{foo}";
		check_augmented_variable "${sigil} {foo}";
		check_augmented_variable "${sigil}{ foo }";
		check_augmented_variable "${sigil} { foo }";

		check_augmented_variable "${sigil}^H";
		check_augmented_variable "${sigil} ^H";
		check_augmented_variable "${sigil}{^H}";
		check_augmented_variable "${sigil} {^H}";
		check_augmented_variable "${sigil}{ ^H }";
		check_augmented_variable "${sigil} { ^H }";

		check_augmented_variable "${sigil}{^GLOBAL_PHASE}";
		check_augmented_variable "${sigil} {^GLOBAL_PHASE}";
		check_augmented_variable "${sigil}{ ^GLOBAL_PHASE }";
		check_augmented_variable "${sigil} { ^GLOBAL_PHASE }";
	}
}

subtest_variables "it should augment scalar variables", '$';
subtest_variables "it should augment list variables", '@';
subtest_variables "it should augment hash variables", '%';

# TODO: numeric variables
# TODO: special variables

had_no_warnings;

done_testing;
