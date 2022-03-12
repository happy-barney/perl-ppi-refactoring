
use v5.14;
use warnings;

package PPIx::Augment::Token::QuoteLike::Regexp {
	use parent qw[ PPIx::Augment::Token::QuoteLike PPI::Token::QuoteLike::Regexp ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::QuoteLike::Regexp - Augmented PPI::Token::QuoteLike::Regexp

=head1 INHERITANCE

	PPIx::Augment::Token::QuoteLike::Regexp
		isa PPIx::Augment::Token::QuoteLike
			isa PPIx::Augment::Token
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Token
					isa PPI::Element
			isa PPI::Token::QuoteLike
				isa PPI::Token
					isa PPI::Element
		isa PPI::Token::QuoteLike::Regexp
			isa PPI::Token::QuoteLike
				isa PPI::Token
					isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
