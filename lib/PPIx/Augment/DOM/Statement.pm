
use v5.14;
use warnings;

package PPIx::Augment::DOM::Statement {
	use parent qw (
		PPIx::Augment::DOM::Node
		PPI::Statement
	);

	use mro q (c3);

	use PPI::Statement v1.278;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Statement - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Statement>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
