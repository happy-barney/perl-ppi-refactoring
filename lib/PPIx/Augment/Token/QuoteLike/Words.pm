
use v5.14;
use warnings;

package PPIx::Augment::Token::QuoteLike::Words {
	use parent qw[ PPIx::Augment::Token::QuoteLike PPI::Token::QuoteLike::Words ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::QuoteLike::Words - Augmented PPI::Token::QuoteLike::Words

=head1 INHERITANCE

	PPIx::Augment::Token::QuoteLike::Words
		isa PPIx::Augment::Token::QuoteLike
			isa PPIx::Augment::Token
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Token
					isa PPI::Element
			isa PPI::Token::QuoteLike
				isa PPI::Token
					isa PPI::Element
		isa PPI::Token::QuoteLike::Words
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
