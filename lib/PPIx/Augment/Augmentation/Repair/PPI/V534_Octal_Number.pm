
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::V534_Octal_Number {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;
	use PPIx::Augment::Token::Number::Octal::v534;

	use namespace::clean;

	sub how_to_augment {
		invoke {
			elements_replace (
				[ current, next_sibling ],
				[ build_token_number_octal (current . next_sibling) ],
			);
		};
	}

	sub what_to_augment {
		where { it_is_token_number q (0) },
		where { its_next_sibling { it_is_token_word qr (^ [oO] _* [0-9] [0-9_]* $)x } },
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::V534_Octal_Number - Recognize v5.34 octal numbers

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Repair::PPI::V534_Octal_Number->augment ($ppi_document)

=head1 DESCRIPTION

Recognizes new octal number syntax added in Perl v5.34

	0o777


As of v1.277 L<PPI> doesn't recognize octal number syntax added in Perl v5.34,
producing tokens C<Number (0)> and C<Word (o...)>. This augmentation replaces
them with an instance of L<PPIx::Augment::Token::Number::Octal::v534>.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

L<PPIx::Augment> distribution is distributed under Artistic Licence 2.0.

=cut
