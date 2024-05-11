
use v5.14;
use warnings;

package PPIx::Refactoring {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;

	use namespace::clean;

	sub how_to_refactor;
	sub what_to_refactor;

	sub new {
		bless {}, shift;
	}

	sub how_to_augment  { shift->how_to_refactor (@_) }
	sub refactor        { shift->augment (@_) }
	sub requires_before_refactoring {
	}

	sub what_to_augment { shift->what_to_refactor (@_) }

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring - Base class for changing PPI document structur

=head1 SYNOPSIS

    my $document = PPIx::Augment::->new ($file);
    my $document = PPIx::Augment::->new (\ $source);
    my $document = PPIx::Augment::->new ($file, (
        Augmentation::Class::
        Augmentation::Another::
    ));

=head1 DESCRIPTION

Improve data structure of PPI documents for easier work with.

=head1 METHODS

=head2 new

    PPIx::Augment::->new ($source, @augmentations?);

Create new L<PPIx::Augment::Document> with provided augmentations applied.

=over

=item C<$source>

Source as L<PPI::Document> understands.

=item C<@augmentations>

List of augmentations to apply.

When no augmentations is provided, applies all augmentations provided by
L</available_augmentations> method.

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

PPIx::Augment distribution is distributed under Artistic Licence 2.0.

=cut
