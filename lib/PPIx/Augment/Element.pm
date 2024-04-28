
use v5.14;
use warnings;

package PPIx::Augment::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);

	use PPI::Element v1.278;

	require PPIx::Augment::No_Element;
	require PPIx::Augment::Scope;

	use constant since_perl => v0.0;
	use constant until_perl => v5.39; # developed with current perl = v5.38

	sub _no_element {
		state $no_element = PPIx::Augment::No_Element::->new;
	}

	sub next_sibling {
		my ($self) = @_;

		return $self->next::method
			|| $self->parent_scope->next_sibling
			;
	}

	sub parent_scope {
		my ($self) = @_;

		return $self->parent
			if $self->parent->isa (PPIx::Augment::Scope::)
			;

		return $self->_no_element;
	}

	sub previous_sibling {
		my ($self) = @_;

		return $self->next::method
			|| $self->parent_scope->previous_sibling
			;
	}

	sub snext_sibling {
		my ($self) = @_;

		return $self->next::method
			|| $self->parent_scope->snext_sibling
			;
	}

	sub sprevious_sibling {
		my ($self) = @_;

		return $self->next::method
			|| $self->parent_scope->sprevious_sibling
			;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Element - Augmented PPI class

=head1 INHERITANCE

    PPIx::Augment::Element
        isa PPI::Element

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Element>.

=head1 METHODS

=head2 parent_scope

Returns C<parent> if it is instance of L<PPIx::Augment::Scope>,
otherwise returns instance of L<PPIx::Augment::No_Element>.

=head2 since_perl

Perl version which introduced syntax represented by class.

Example:

=over

=item package block was introduced in v5.12

=item package version was introduced in v5.14

=item function signature was introduced in v5.20

=back

=head2 until_perl

Perl version which disabled syntax represented by class.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

