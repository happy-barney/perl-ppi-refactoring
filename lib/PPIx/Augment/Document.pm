
use v5.14;
use warnings;

package PPIx::Augment::Document {
	use parent qw (
		PPIx::Augment::Node
		PPI::Document
	);

	use mro q (c3);

	use PPI v1.278;
	use Ref::Util;
	use Safe::Isa;
	use Scalar::Util;

	sub _build_requires_map {
		my (@augmentations) = @_;

		my %required;
		while (my $augmentation = shift @augmentations) {
			next if $required{$augmentation};
			push @augmentations, @{ $required{$augmentation} = [ $augmentation->requires ] };
		}

		return %required;
	}

	sub _is_augmentation_up_to_date {
		my ($self, $augmentation) = @_;

		return
			unless my $last_update = $self->{_epoch_mapping}{$augmentation}
			;

		return $last_update == $self->{_epoch};
	}

	sub new {
		my ($class, $source, @args) = @_;

		if (Scalar::Util::blessed ($source)) {
			$source = $source->stringify
				if $source->$Safe::Isa::_DOES (q (Path::Tiny))
				;

			$source = $source->clone
				if $source->$Safe::Isa::_DOES (q (PPI::Document))
				;
		}

		$source = PPI::Document::->new ($source, @args)
			unless Scalar::Util::blessed ($source)
			;

		$source->{_epoch} = 1;
		$source->{_epoch_mapping} = { };

		return bless $source, ref ($class) || $class;
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

		my $last_epoch = $self->{_epoch};

		for my $augmentation (@with_augmentations) {
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

			$self->{_epoch_mapping}{$augmentation} = $self->{_epoch};
		}

		return $self->{_epoch} == $last_epoch;
	}

	1;
}

__END__


	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Document - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Document>.

=head1 METHODS

=head2 augment

    $document->augment (@augmentations);

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

