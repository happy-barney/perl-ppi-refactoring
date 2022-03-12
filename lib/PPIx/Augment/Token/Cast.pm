
use v5.14;
use warnings;

package PPIx::Augment::Token::Cast {
	use parent qw[ PPIx::Augment::Token PPI::Token::Cast ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Cast - Augmented PPI::Token::Cast

=head1 INHERITANCE

	PPIx::Augment::Token::Cast
		isa PPIx::Augment::Token
			isa PPIx::Augment::Element
				isa PPI::Element
			isa PPI::Token
				isa PPI::Element
		isa PPI::Token::Cast
			isa PPI::Token
				isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
