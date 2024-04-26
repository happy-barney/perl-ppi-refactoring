
use v5.14;
use warnings;

package PPIx::Augment {

	use Module::Find;
	use Module::Load;
	use PPI 1.278;
	use Safe::Isa qw ($_DOES);

	require PPIx::Augment::Document;
	require PPIx::Augment::Augmentation;

	sub _prepare_source {
		my ($self, $source) = @_;

		$source = PPIx::Augment::Document::->new ($source)
			unless $source->$_DOES (PPIx::Augment::Document::)
			;

		$source;
	}

	sub augment {
		my ($self, $source, @augmentations) = @_;

		$source = $self->_prepare_source ($source);

		$source->augment (@augmentations);

		return $source;
	}

	sub available_augmentations {
		my ($self, $root) = @_;

		$root //= PPIx::Augment::Augmentation::;

		state %augmentations;

		return @{
			$augmentations{$root} //= [
				grep { $_->$_DOES (PPIx::Augment::Augmentation::) }
				grep { eval { Module::Load::load ($_) } }
				Module::Find::findallmod ($root)
			]
		};
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment - Improve structure of PPI document

=head1 SYNOPSIS

    my $document = PPIx::Augment::->augment ($file);
    my $document = PPIx::Augment::->augment (\ $source);
    my $document = PPIx::Augment::->augment ($file, (
        Augmentation::Class::
        Augmentation::Another::Class::
    ));

=head1 DESCRIPTION

Improve data structure of PPI documents for easier work with.

=head1 METHODS

=head2 augment

    PPIx::Augment::->augment ($source, @augmentations?);

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
