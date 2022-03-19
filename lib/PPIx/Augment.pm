
use v5.14;
use warnings;

package PPIx::Augment {
	require PPIx::Augment::Elements;

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
