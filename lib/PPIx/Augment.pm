
use v5.14;
use warnings;

package PPIx::Augment {
	use parent q (PPI::Document);

	use mro q (c3);

	use Module::Find;
	use Module::Load;
	use PPI v1.278;

	use PPIx::Augment::Augmentation;

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

		$source->augment (@augmentations);

		return $source;
	}

	sub _is_augmentation_up_to_date {
		my ($self, $augmentation) = @_;

		return
			unless my $last_update = $self->{_epoch_mapping}{$augmentation}
			;

		return $last_update == $self->{_epoch};
	}

	sub _obsoleted_requirements {
		my ($self, $augmentation) = @_;

		return
			grep { ! $self->_is_augmentation_up_to_date ($_) }
			$augmentation->requires
			;
	}

	sub augment {
		my ($self, @with_augmentations) = @_;

		return
			unless @with_augmentations
			;

		my $starting_epoch = $self->{_epoch};

		for my $augmentation (@with_augmentations) {
			# Optimistic handling of cycles - expect them to break naturally
			next
				if $self->_is_augmentation_up_to_date ($augmentation)
				;

			if (my @requires = $self->_obsoleted_requirements ($augmentation)) {
				unshift @with_augmentations, @requires, $augmentation;
				next;
			}

			$self->{_epoch}++
				if $augmentation->augment ($self)
				;
		} continue {
			$self->{_epoch_mapping}{$augmentation} = $self->{_epoch};
		}

		# current epoch and starting epoch doesn't match => something was modified
		return $self->{_epoch} != $starting_epoch;
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

	sub consolidate {
		my ($self) = @_;

		my @augmentations = keys %{ $self->{_epoch_mapping} };

		1
			while $self->augment (@augmentations)
			;
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
    my $document = PPIx::Augment::->new (
        $file,
        { tab_width => 4 },
        Augmentation::Class::
        Augmentation::Another::Class::
    );

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

=head2 augment

    $ppix_augment->augment (@with_augmentations)

Applies specified augmentations.

=head2 available_augmentations

Returns list of available augmentations.

The method searches for all modules under L</available_augmentations_root>
extending L<PPIx::Augment::Augmentation>.

=head2 available_augmentations_root

Default: L<PPIx::Augment::Augmentation>.

=head2 consolidate

L<PPIx::Augment> uses a lazy approach to augment the data model, applying augmentations
only when they are needed, so it does not automatically re-evaluate already applied
augmentations when changes are applied.

One can use the method L</augment> with proper arguments or call this method, which
is a shortcut for calling L</augment> with all applied augmentations.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

The PPIx::Augment distribution is distributed under the Artistic Licence 2.0.

=cut
