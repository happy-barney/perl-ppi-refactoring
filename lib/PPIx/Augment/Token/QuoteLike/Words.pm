
use v5.14;
use warnings;

package PPIx::Augment::Token::QuoteLike::Words {
	use parent qw (
		PPIx::Augment::Token::QuoteLike
		PPI::Token::QuoteLike::Words
	);

	use mro q (c3);

	use PPI::Token::QuoteLike::Words v1.278;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::QuoteLike::Words - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Token::QuoteLike::Words>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

