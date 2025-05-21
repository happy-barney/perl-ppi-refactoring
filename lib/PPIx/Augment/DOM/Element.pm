
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);
	use version;

	use PPI v1.278;

	use constant since_perl => undef;
	use constant until_perl => undef;

	sub add_trait {
		my ($self, $trait) = @_;

		$self->{_traits}{$trait} = 1;
	}

	sub is_available_for {
		my ($self, $perl_version) = @_;

		$perl_version = version->parse ($perl_version);

		my $is_available = 1;

		$is_available &&= $perl_version < version->parse ($self->since_perl)
			if defined $self->since_perl
			;

		$is_available &&= version->parse ($self->until_perl) < $perl_version
			if defined $self->until_perl
			;

		return $is_available;
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

PPIx::Augment::DOM::Element - Base class of augmented DOM tree

=head1 INHERITANCE

TODO

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Element>.

=head1 METHODS

=head2 is_available_for ($perl_version)

    $element->is_available_for (v5.12);

Using the L</since_perl> and L</until_perl> methods determines whether an element
is available for the given Perl version.

=head2 since_perl

    use constant since_perl => v5.12;

Perl version which introduced the syntax represented by the class / the object.

C<undef> is treated as the lowest possible value.

Examples:

=over

=item Package block was introduced in v5.12

=item Package version was introduced in v5.14

=item Function signature was introduced in v5.20

=back

=head2 until_perl

    use constant until_perl => v5.22;

Perl version which disabled the syntax represented by the class / the object.

C<undef> is treated as the highest possible value.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
