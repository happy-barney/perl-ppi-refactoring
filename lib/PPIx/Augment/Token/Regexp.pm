
use v5.14;
use warnings;

package PPIx::Augment::Token::Regexp {
	use parent qw[ PPIx::Augment::Token PPI::Token::Regexp ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Regexp - Augmented PPI::Token::Regexp

=head1 INHERITANCE

	PPIx::Augment::Token::Regexp
		isa PPIx::Augment::Token
			isa PPIx::Augment::Element
				isa PPI::Element
			isa PPI::Token
				isa PPI::Element
		isa PPI::Token::Regexp
			isa PPI::Token
				isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
