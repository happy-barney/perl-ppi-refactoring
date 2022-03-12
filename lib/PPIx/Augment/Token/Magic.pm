
use v5.14;
use warnings;

package PPIx::Augment::Token::Magic {
	use parent qw[ PPIx::Augment::Token::Symbol PPI::Token::Magic ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Magic - Augmented PPI::Token::Magic

=head1 INHERITANCE

	PPIx::Augment::Token::Magic
		isa PPIx::Augment::Token::Symbol
			isa PPIx::Augment::Token
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Token
					isa PPI::Element
			isa PPI::Token::Symbol
				isa PPI::Token
					isa PPI::Element
		isa PPI::Token::Magic
			isa PPI::Token::Symbol
				isa PPI::Token
					isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
