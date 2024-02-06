
use v5.14;
use warnings;

package PPIx::Augment::Structure::Signature {
	use parent qw[ PPI::Structure ];
	use PPI;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Structure::Signature - Represents subroutine signatures

=head1 INHERITANCE

	PPIx::Augment::Structure::Signature
		isa PPI::Structure
			isa PPI::Node
				isa PPI::Element
		PPI::Token::Prototype
			isa PPI::Token
				isa PPI::Element

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
