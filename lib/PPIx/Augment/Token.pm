
use v5.14;
use warnings;

package PPIx::Augment::Token {
	use parent qw[ PPIx::Augment::Element PPI::Token ];

	use PPIx::Augment::Token::Operator::Arrow;
	use PPIx::Augment::Token::Operator::Comma;
	use PPIx::Augment::Token::Operator::Fat_Comma;
	use PPIx::Augment::Token::Operator::Question_Mark;

	sub augment {
		my ($class, $token) = @_;

		bless $token, $class
			unless $token->isa (__PACKAGE__);

		return $token;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token - Augmented PPI::Token

=head1 INHERITANCE

	PPIx::Augment::Token
		isa PPIx::Augment::Element
			isa PPI::Element
		isa PPI::Token
			isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
