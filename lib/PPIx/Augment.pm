
use v5.14;
use warnings;

package PPIx::Augment {

	use Module::Find;
	use Module::Load;
	use PPI 1.278;
	use Safe::Isa qw ($_DOES);
	use Scalar::Util;

	require PPIx::Augment::Document;
	require PPIx::Augment::Augmentation;

	sub _prepare_source {
		my ($self, $source, $options) = @_;

		if (Scalar::Util::blessed ($source)) {
			$source = $source->stringify
				if $source->$_DOES (+q (Path::Tiny))
				;

			$source = $source->$_DOES (PPIx::Augment::Document::)
				? $source->clone
				: PPIx::Augment::Document::->new ($source, %$options)
				;
		}

		$source;
	}

	sub augment {
		my ($self, $source, %flags) = @_;

		my $augmentations = delete $flags{augmentations};
		my $augmentations_root = delete $flags{augmentations_root};

		my $options = Ref::Util::is_plain_hashref ($augmentations[0])
			? shift @augmentations
			: { }
			;

		$source = $self->_prepare_source ($source, $options);

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

PPIx::Augment - Augment structure of PPI document

=head1 SYNOPSIS

    my $document = PPIx::Augment::->augment ($file);
    my $document = PPIx::Augment::->augment (\ $source);
    my $document = PPIx::Augment::->augment (
        $file,
        tab_width => 4,
        augmentations => [
            Augmentation::Class::
            Augmentation::Another::Class::
        ],
    );

=head1 DESCRIPTION

L<PPIx::Augment> extends L<PPI> data model with focus to simplify
automated source code processing (especially refactoring).

=head1 METHODS

=head2 augment

    PPIx::Augment::->augment ($source, %flags?);

Method recognizes same arguments as L<PPI::Document>.

In addition, C<$source> can be:

=over

=item instance of PPI::Document

Returns clone of provided C<$source>.

=item instance of Path::Tiny

File path to parse can be specified also using L<Path::Tiny>.
Create an instance of L<PPIx::Augment::Document>.

The method accepts same arguments as L<PPI::Document>, recognizing  additional flags:

=over

=item augmentations

    PPIx::Augment->augment ($source, augmentations => [ ... ]);

Function  C<augmentations>
containing list of augmentations to be implicitely applied on document.

When C<augmentations> flag isn't provided, all available augmentations will be applied.

When it contains empty arrayref, no augmentation is applied by default.

=head2 available_augmentations


=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

PPIx::Augment distribution is distributed under Artistic Licence 2.0.

=cut
