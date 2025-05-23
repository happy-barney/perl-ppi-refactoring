
use v5.14;
use warnings;

package PPIx::Augment {
	use parent q (PPI::Document);

	use mro q (c3);

	use Module::Find;
	use Module::Load;
	use PPI v1.278;

	sub new {
		my ($class, $source, @with_augmentations) = @_;

		my $flags = Ref::Util::is_plain_hashref ($with_augmentations[0])
			? shift
			: { }
			;

		if (Scalar::Util::blessed ($source)) {
			$source = $source->stringify
				if $source->$Safe::Isa::_DOES (q (Path::Tiny))
				;

			$source = $source->clone
				if $source->$Safe::Isa::_DOES (q (PPI::Document))
				;
		}

		$source = $class->next::method ($source, %$flags)
			unless Scalar::Util::blessed ($source)
			;

		$source->tab_width ($flags->{tab_width})
			if exists $flags->{tab_width}
			;

		$source->{_epoch} = 1;
		$source->{_epoch_mapping} = { };

		$source = bless $source, ref ($class) || $class;

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

    my $document = PPIx::Augment::->new ($file);
    my $document = PPIx::Augment::->new (\ $source);
    my $document = PPIx::Augment::->new ($ppi_document);

=head1 INHERITANCE

PPIx::Augment

=over

=item isa L<PPI::Document>

=back

=head1 DESCRIPTION

L<PPIx::Augment> extends the L<PPI> data model with focus on simplifying
automated source code processing (especially refactoring).

=head1 PERFORMANCE

Be aware that this module is heavily under-optimised, focusing on delivering
functionality first, performance later.

=head1 METHODS

=head2 new

    PPIx::Augment::->new ($source, $ppi_options?, @with_augmentations);

=over

=item C<$source>

Document to parse and augment. Recognized values:

=over

=item instance of C<PPI::Document>

PPIx::Augment clones given C<$source>.

=item instance of C<Path::Tiny>

Value is stringified and forwarded to L<PPI::Document>'s C<new>.

=item SCALAR or unblessed reference

Value is forwarded to L<PPI::Document>'s C<new>.

=back

=item C<$ppi_options>

Optional hashref, forwarded to L<PPI::Document>'s C<new>.

In addition, L<PPIx::Augment> recognises and sets C<tab_width>.

=item C<@with_augmentations>

Applies specified augmentations during construction.

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

The PPIx::Augment distribution is distributed under the Artistic Licence 2.0.

=cut
