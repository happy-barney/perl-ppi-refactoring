
use v5.14;
use warnings;

package PPIx::Augment::Token::Symbol {
	use parent qw[ PPIx::Augment::Token PPI::Token::Symbol ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Symbol - Augmented PPI::Token::Symbol

=head1 INHERITANCE

	PPIx::Augment::Token::Symbol
		isa PPIx::Augment::Token
			isa PPIx::Augment::Element
				isa PPI::Element
			isa PPI::Token
				isa PPI::Element
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
