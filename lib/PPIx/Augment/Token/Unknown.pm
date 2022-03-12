
use v5.14;
use warnings;

package PPIx::Augment::Token::Unknown {
	use parent qw[ PPIx::Augment::Token PPI::Token::Unknown ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Unknown - Augmented PPI::Token::Unknown

=head1 INHERITANCE

	PPIx::Augment::Token::Unknown
		isa PPIx::Augment::Token
			isa PPIx::Augment::Element
				isa PPI::Element
			isa PPI::Token
				isa PPI::Element
		isa PPI::Token::Unknown
			isa PPI::Token
				isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
