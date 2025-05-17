
use v5.14;
use warnings;

package PPIx::Augment::Document {
	use parent qw (
		PPI::Document
	);

	use mro q (c3);

	use PPI v1.278;
	use Ref::Util;
	use Safe::Isa qw ($_DOES);

	sub _build_requires_map {
		my (@augmentations) = @_;

		my %required;
		while (my $augmentation = shift @augmentations) {
			next if $required{$augmentation};
			push @augmentations, @{ $required{$augmentation} = [ $augmentation->requires ] };
		}

		return %required;
	}

	sub new {
		my ($class, $source, @args) = @_;

		my $document = $source->$_DOES (PPI::Document::)
			? $source
			: PPI::Document::->new ($source, @args)
			;

		bless $document, $class;
	}

	sub augment {
		my ($self, @augmentations) = @_;

		for my $step ($self->augmentation_apply_order (@augmentations)) {
			$step->augment ($self);
		}

		return $self;
	}

	sub augmentation_apply_order {
		my ($self, @augmentations) = @_;

		my %required = _build_requires_map (@augmentations);

		my @apply_order;
		my (%seen, %watching);

		for my $augmentation (@augmentations) {
			my @queue = ($augmentation);
			while (my $step = shift @queue) {
				next if exists $seen{$step};

				if (Ref::Util::is_plain_ref ($step)) {
					$seen{$$step} = delete $watching{$$step};

					push @apply_order, $$step;
					next;
				}

				die qq (Dependency cycle detected in $augmentation <-> $step)
					if exists $watching{$step}
					;

				$watching{$step} = 1;
				unshift @queue, \ $step;
				unshift @queue, @{ $required{$step} };
			}
		}

		return @apply_order;
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

