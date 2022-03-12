
use v5.14;
use warnings;

package PPIx::Augment::Token::Number::Version {
	use parent qw[ PPIx::Augment::Token::Number PPI::Token::Number::Version ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Number::Version - Augmented PPI::Token::Number::Version

=head1 INHERITANCE

	PPIx::Augment::Token::Number::Version
		isa PPIx::Augment::Token::Number
			isa PPIx::Augment::Token
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Token
					isa PPI::Element
			isa PPI::Token::Number
				isa PPI::Token
					isa PPI::Element
		isa PPI::Token::Number::Version
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
