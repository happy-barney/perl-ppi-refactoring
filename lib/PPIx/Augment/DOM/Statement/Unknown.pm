
use v5.14;
use warnings;

package PPIx::Augment::DOM::Statement::Unknown {
	use parent qw (
		PPIx::Augment::DOM::Statement
		PPI::Statement::Unknown
	);

	use mro q (c3);

	use PPI v1.278;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Statement::Unknown - Augmented PPI class

=head1 INHERITANCE

TODO

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Statement::Unknown>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
