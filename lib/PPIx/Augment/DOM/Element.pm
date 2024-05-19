
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);

	use PPI::Element v1.278;

	use constant since_perl         => v5.0;
	use constant until_perl         => v6.0;
	use constant deprecated_in_perl => v6.0;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Element - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Element>.

=head1 METHODS

=head2 since_perl

Default value: C<v5.0>

Version of Perl which introduced syntax represented by given element.

=head2 until_perl

Default value: C<v6.0>

Version of Perl which removed syntax represented by given element.

=head2 deprecated_in_perl

Default value: C<v6.0>

Version of Perl which deprecated syntax represented by given element.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
