
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

	sub augment {
		my ($class, $source, @augmentations) = @_;

		my $options = Ref::Util::is_plain_ref ($augmentations[0])
			? shift @augmentations
			: { }
			;

		$source = $class->document ($source, %$options);

		$source->augment (@augmentations);

		return $source;
	}

	sub available_augmentations {
		my ($class, $root) = @_;

		$root //= $class->available_augmentations_root;

		state %augmentations;

		return @{
			$augmentations{$root} //= [
				grep { $_->$_DOES (PPIx::Augment::Augmentation::) }
				grep { eval { Module::Load::load ($_) } }
				Module::Find::findallmod ($root)
			]
		};
	}

	sub available_augmentations_root {
		return PPIx::Augment::Augmentation::;
	}

	sub document {
		my ($class, $source, %flags) = @_;

		if (Scalar::Util::blessed ($source)) {
			$source = $source->stringify
				if $source->$_DOES (+q (Path::Tiny))
				;

			$source = $source->$_DOES (PPIx::Augment::Document::)
				? $source->clone
				: PPIx::Augment::Document::->new ($source, %flags)
				;
		}

		$source->tab_width ($flags{tab_width})
			if exists $flags{tab_width}
			;

		return $source;
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
        { tab_width => 4 },
        Augmentation::Class::
        Augmentation::Another::Class::
    );

=head1 DESCRIPTION

L<PPIx::Augment> extends L<PPI> data model with focus to simplify
automated source code processing (especially refactoring).

=head1 METHODS

=head2 augment

    PPIx::Augment::->augment ($source, $options?, @augmentations?);

=over

=item C<$source>

In addition to values recognized by L<PPI::Document>, C<$source> can be:

=over

=item instance of PPI::Document

Returns clone of provided C<$source>.

=item instance of Path::Tiny

File path to parse can be specified also using L<Path::Tiny>.
Create an instance of L<PPIx::Augment::Document>.

=back

=item C<$options>

Optional, when provided, it should be hashref containing flags supported by
L<PPI::Document>. In addition, there can be flag C<tab_width>.

=item C<@augmentations>

List of augmentations to be applied.

When not specified, L</available_augmentations> will be applied.

=head2 available_augmentations

    PPIx::Augment::->available_augmentations ($root?);

Returns all installed augmentations starting with C<$root>.
When not specified, L</available_augmentations_root> is used.

=head2 available_augmentations_root

Default value: C<PPIx::Augment::Augmentation>.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

PPIx::Augment distribution is distributed under Artistic Licence 2.0.

=cut
