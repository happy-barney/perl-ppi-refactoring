
use v5.14;
use warnings;

package PPIx::Augment {
	require PPIx::Augment::Elements;

	require PPIx::Augment::Augmentation::Rebless;
	require PPIx::Augment::Fix::Magic_Cast;
	require PPIx::Augment::Fix::New_Octal_Numbers;
	require PPIx::Augment::Fix::Ternary_Operator_Colon;

	our $VERBOSE = 0;
	our $TRACE = 0;

	sub verbose (&) {
		($VERBOSE || $TRACE) && say '[Augment] ', $_[0]->();
	}

	sub trace (&) {
		$TRACE && say '[Augment] ', '|> ', $_[0]->();
	}

	sub augment {
		my ($self, $document) = @_;

		&PPIx::Augment::Augmentation::Rebless::augment;

		&fix;

		verbose { "Organize document little bit better" };

		&$_ for grep { $_ } map { ($_->can ('requires'), $_->can ('augment')) } (
		);

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
