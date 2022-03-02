
use v5.14;
use warnings;

package PPIx::Augment {
	require PPIx::Augment::Elements;

	require PPIx::Augment::Augmentation::Rebless;
	require PPIx::Augment::Fix::Magic_Cast;
	require PPIx::Augment::Fix::New_Octal_Numbers;
	require PPIx::Augment::Fix::Ternary_Operator_Colon;
	use PPIx::Augment::Token::Operator::Arrow;
	use PPIx::Augment::Expression::Call::Method;

	require PPIx::Augment::Augmentation::Term::Anonymous;
	require PPIx::Augment::Augmentation::Term::Dereference;
	require PPIx::Augment::Augmentation::Term::Do_Block;
	require PPIx::Augment::Augmentation::Term::Literal;
	require PPIx::Augment::Augmentation::Term::Variable;
	require PPIx::Augment::Augmentation::Expression::Reference;

	our $VERBOSE = 0;
	our $TRACE = 0;

	sub verbose (&) {
		($VERBOSE || $TRACE) && say '[Augment] ', $_[0]->();
	}

	sub trace (&) {
		$TRACE && say '[Augment] ', '|> ', $_[0]->();
	}

	sub augment_operator_arrow {
		my ($self, $document) = @_;
		my $augment_package = 'PPIx::Augment::Token::Operator::Arrow';

		bless $_, $augment_package
			for
			grep { $_->content eq '->' }
			grep { ! $_->isa ($augment_package) }
			ppi_find ($document, 'PPI::Token::Operator')
			;
	}

	sub augment_method_call {
		my ($self, $document) = @_;

		&augment_operator_arrow;

		my @arrows = ppi_find ($document, sub { $_[1]->isa ('PPIx::Augment::Token::Operator::Arrow') });

		for my $element (@arrows) {
			use feature 'say';
			say "arrow found at ${\ ppi_location ($element) }";

			PPIx::Augment::Expression::Call::Method->new;
		

			d $element->sprevious_sibling;
		}
	}


	sub augment {
		my ($self, $document) = @_;

		&PPIx::Augment::Augmentation::Rebless::augment;

		&fix;

		verbose { "Organize document little bit better" };

		&$_ for grep { $_ } map { ($_->can ('requires'), $_->can ('augment')) } (
			PPIx::Augment::Augmentation::Term::Anonymous::,
			PPIx::Augment::Augmentation::Term::Dereference::,
			PPIx::Augment::Augmentation::Term::Do_Block::,
			PPIx::Augment::Augmentation::Term::Literal::,
			PPIx::Augment::Augmentation::Term::Variable::,
		);

		&augment_operator_arrow;
		&augment_method_call;

		$document;
	}

	sub fix {
		my ($self, $document) = @_;

		verbose { "Fix some PPI problems" };

		&$_ for grep { $_ } map { ($_->can ('requires'), $_->can ('fix')) } (
			PPIx::Augment::Fix::Magic_Cast::,
			PPIx::Augment::Fix::New_Octal_Numbers::,
			PPIx::Augment::Fix::Ternary_Operator_Colon::,
		);

		$document;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment - Improve structure of PPI document

=head1 DESCRIPTION

Fix some bugs and improve structre of PPI documents

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

Test::YAFT distribution is distributed under Artistic Licence 2.0.

=cut
