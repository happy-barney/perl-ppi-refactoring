
use v5.14;
use warnings;

package PPIx::Augment::Token::Regexp::Match {
	use parent qw (
		PPIx::Augment::Token::Regexp
		PPI::Token::Regexp::Match
	);

	use mro q (c3);

	use PPI::Token::Regexp::Match v1.278;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Regexp::Match - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Token::Regexp::Match>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

