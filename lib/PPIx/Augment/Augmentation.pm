
use v5.14;
use warnings;

package PPIx::Augment::Augmentation {
	use PPIx::Augment::Internals qw (flatten_array);
	use PPIx::Augment::Utils qw (ppix_search ppix_transform);

	use namespace::autoclean;

	use constant how_to_augment  => ();
	use constant requires        => ();

	sub analyze {
		my ($self, $document) = @_;

		return
			map { ppix_search $document, flatten_array ($_->{where}) }
			$self->how_to_augment ($document)
			;
	}

	sub augment {
		my ($self, $document) = @_;

		my $rv = 0;
		for my $item ($self->how_to_augment) {
			$rv += ppix_transform $document
				=> flatten_array ($item->{where})
				=> flatten_array ($item->{invoke})
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

PPIx::Augment::Augmentation - Base class for augmentations of PPI documents

=head1 DESCRIPTION

=head1 METHODS

=head2 how_to_augment

    my @plan = $self->how_to_augment;

    # example of @plan item
    {
        id     => q (search path 1),
        invoke => invoke { ... },
        where  => where { ... },
    }

An augmentation may augment multiple different search paths with different transformation code.
To support that, the method can return a list of hashrefs, one for each approach.

Hashref must contain keys:

=over

=item id

Optional, for easier identification of what is going on.

=item invoke

Function augmenting the leading object of augmentation, for example
value of C<invoke { }|PPIx::Augment::Utils/invoke (&)>.

=item where

Function identifying the element objects of augmentation, for example
value C<where { }|PPIx::Augment::Utils/where (&)>.

=back

=head2 analyze ($document)

    my @elements = $augmentation->analyze ($document);

The default implementation processes the output of L</how_to_augment>,
returning elements to augment.

=head2 augment ($document)

    my $number_of_transformed_elements = $augmentation->augment ($document);

The default implementation processes the output of L</how_to_augment>,
applying augmentations.

Method should return number of transformed elements.
It must return C<0> (zero) when no element was augmented.

=head2 requires

Returns a list of prerequisite augmentations.

Default: empty list

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
