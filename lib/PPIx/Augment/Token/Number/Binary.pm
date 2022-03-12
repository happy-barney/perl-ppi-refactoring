
use v5.14;
use warnings;

package PPIx::Augment::Token::Number::Binary {
	use parent qw[ PPIx::Augment::Token::Number PPI::Token::Number::Binary ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Number::Binary - Augmented PPI::Token::Number::Binary

=head1 INHERITANCE

	PPIx::Augment::Token::Number::Binary
		isa PPIx::Augment::Token::Number
			isa PPIx::Augment::Token
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Token
					isa PPI::Element
			isa PPI::Token::Number
				isa PPI::Token
					isa PPI::Element
		isa PPI::Token::Number::Binary
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
