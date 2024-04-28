
use v5.14;
use warnings;

package PPIx::Augment::Scope {
	use parent qw (
		PPIx::Augment::Node
	);

	use mro q (c3);

	use PPI::Document v1.278;

	1;
}

__END__


	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Scope - Augmented class

=head1 INHERITANCE

=head1 DESCRIPTION

Base class for marker classes projecting informations into parent - child hierarchy.

Scope doesn't break C<sibling> relation - C<*_sibling> of last element in scope
is same kind of sibling of scope element.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

