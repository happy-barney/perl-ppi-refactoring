
use v5.14;
use warnings;

package PPIx::Augment::Token::Number::Exp {
	use parent qw[ PPIx::Augment::Token::Number::Float PPI::Token::Number::Exp ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Number::Exp - Augmented PPI::Token::Number::Exp

=head1 INHERITANCE

	PPIx::Augment::Token::Number::Exp
		isa PPIx::Augment::Token::Number::Float
			isa PPIx::Augment::Token::Number
				isa PPIx::Augment::Token
					isa PPIx::Augment::Element
						isa PPI::Element
					isa PPI::Token
						isa PPI::Element
				isa PPI::Token::Number
					isa PPI::Token
						isa PPI::Element
			isa PPI::Token::Number::Float
				isa PPI::Token::Number
					isa PPI::Token
						isa PPI::Element
		isa PPI::Token::Number::Exp
			isa PPI::Token::Number::Float
				isa PPI::Token::Number
					isa PPI::Token
						isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
