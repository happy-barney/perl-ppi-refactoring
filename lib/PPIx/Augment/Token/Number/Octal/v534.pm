
use v5.14;
use warnings;

package PPIx::Augment::Token::Number::Octal::v534 v1.0.0 {
	use parent qw (PPIx::Augment::Token::Number::Octal);

	use constant since_perl => v5.34;

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Token::Number::Octal::v534

=head1 INHERITANCE

    PPIx::Augment::Token::Number::Octal::v534
        isa PPIx::Augment::Token::Number::Octal
            PPIx::Augment::Token::Number
                isa PPIx::Augment::Token
                    isa PPIx::Augment::Element
            isa PPI::Token::Number::Octal
                isa PPI::Token::Number
                    isa PPI::Token
                        isa PPI::Element

=head1 DESCRIPTION

Represents octal literal syntax introduced in Perl v5.34.

	0o123

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
