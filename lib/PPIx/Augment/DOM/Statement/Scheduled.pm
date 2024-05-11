
use v5.14;
use warnings;

package PPIx::Augment::DOM::Statement::Scheduled {
	use parent qw (
		PPIx::Augment::DOM::Statement::Sub
		PPI::Statement::Scheduled
	);

	use mro q (c3);

	use PPI::Statement::Scheduled v1.278;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Statement::Scheduled - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Statement::Scheduled>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
