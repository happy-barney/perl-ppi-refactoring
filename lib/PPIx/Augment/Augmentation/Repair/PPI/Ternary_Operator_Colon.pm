
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::Ternary_Operator_Colon {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;

	use namespace::clean;

	sub what_to_augment {
		where { it_is_token_label },
		where { its_sprevious_sibling { it_is_token_operator } },
	}

	sub how_to_augment {
		invoke {
			my ($word, $whitespace, $colon) = current =~ m (^(\w+)(\s*)(:)$);

			elements_replace current, [
				build_token_word       $word,
				build_token_whitespace $whitespace,
				build_token_operator   $colon,
			];
		}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::Ternary_Operator_Colon - fix PPI issues

=head1 SYNOPSIS

	$augment_document->augment (PPIx::Augment::Augmentation::Repair::PPI::Ternary_Operator_Colon::);

=head1 DESCRIPTION

As of v1.277 PPI erroneously recognizes words in ternary expression's then-clause
as label.

	$condition ? true : false;
	$condition ? JSON->true : JSON->false;

Both C<true> words will be parsed as L<PPI::Token::Label>

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
