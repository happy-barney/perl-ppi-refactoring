
use v5.14;
use warnings;

package PPIx::Augment::Structure::Signature {
	use parent qw (
		PPIx::Augment::Structure
		PPI::Token::Prototype
	);

	use mro q (c3);

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Structure::Signature

=head1 INHERITANCE

=head1 DESCRIPTION

New element representing function signature.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
