
use v5.14;
use warnings;

package PPIx::Refactor {

	use Safe::Isa qw ($_isa);

	use PPIx::Augment;
	use PPIx::Augment::Document;
	use PPIx::Refactoring;

	sub new {
		my ($class, @refactorings) = @_;

		bless [
			PPIx::Augment::Document::->augmentation_apply_order (@refactorings)
		], $class;
	}

	sub analyze {
		my ($self, $source) = @_;
		my $document = PPIx::Augment::->_prepare_source ($source);

		return map { $_->analyze ($document) } @$self;
	}

	sub refactor {
		my ($self, $source) = @_;
		my $document = PPIx::Augment::->_prepare_source ($source);

		my $rv = 0;
		for my $step (@$self) {
			$step->isa (PPIx::Refactoring::)
				? ($rv += $step->refactor ($document))
				: $step->augment ($document)
				;
		}

		return $rv;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactor - Refactor PPI document

=head1 SYNOPSIS

    my $refactoring = PPIx::Refactor::->new (@refactorings);
    my $document = $refactoring->refactor ($source);

=head1 DESCRIPTION

Refactor structure of PPI documents.

Difference between C<refactoring> and C<augmentation> is that
augmentation is not supposed to change text of L<PPI::Document>,
only to modify it's data representation.

=head1 METHODS

=head2 new

    PPIx::Refactor::->new (@refactorings);

=head2 refactor

    my $modified = $refactoring->refactor ($document);

Applies refactorings represented by C<$refactoring> on C<$document>.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

PPIx::Augment distribution is distributed under Artistic Licence 2.0.

=cut
