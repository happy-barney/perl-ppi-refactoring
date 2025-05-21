
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);

	use PPI v1.278;

	sub add_trait {
		my ($self, $trait) = @_;

		$self->{_traits}{$trait} = 1;
	}

	sub isa {
		my ($self, $trait) = @_;

		return 1
			if $self->{_traits}
			&& exists $self->{_traits}{$trait}
			;

		return $self->next::method ($trait);
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Element - Augmented PPI class

=head1 INHERITANCE

TODO

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Element>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
