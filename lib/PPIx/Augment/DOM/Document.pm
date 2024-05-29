
use v5.14;
use warnings;

package PPIx::Augment::DOM::Document {
	use parent qw (
		PPIx::Augment::DOM::Node
		PPI::Document
	);

	use mro q (c3);

	use PPI::Document v1.278;

	use PPIx::Augment::Augmentation::DOM;

	sub new {
		my ($class, $source, @args) = @_;

		my $document = $source->$_DOES (PPI::Document::)
			? $source
			: PPI::Document::->new ($source, @args)
			;

		bless $document, $class;
		$document->{x_epoch}     = 0;
		$document->{x_augmented} = {};

		$document->augment (
			PPIx::Augment::Augmentation::DOM::,
		);

		return $document;
	}

	sub augment {
		my ($self, @augmentations) = @_;

		my $epoch     = $self->{x_epoch} //= 0;
		my $augmented = $self->{x_augmented} //= {};

		while (my $step = shift @augmentations) {
			my @requires =
				grep { ($augmented->{$_} // 0) < $epoch }
				$step->requires,
				$step
				;

			if (@requires > 1) {
				unshift @augmentations, @requires;
				next;
			}

			$self->{x_epoch} = ++$epoch
				if $step->augment ($self)
				;

			$augmented->{$step} = $epoch;
		}

		return $self;
	}


	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Document - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Document>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
