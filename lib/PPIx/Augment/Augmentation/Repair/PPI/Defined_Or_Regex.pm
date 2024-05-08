
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::Defined_Or_Regex {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;

	use namespace::clean;

	sub how_to_augment {
		invoke {
			elements_replace
				[ current ],
				[ build_token_regexp_match q (//) ]
				;
		}
	}

	sub what_to_augment {
		where {
			it_is_operator_defined_or
			and its_sprevious_sibling {
				it_is_token_word
				and it_is_not {
					its_sprevious_sibling { it_is_token_operator q (->) }
				}
			}
		}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::Defined_Or_Regex

=head1 DESCRIPTION

This augmentation augments document so it follows Perl parser.

As of v5.38, Perl treats such C<//> as regexp.

As of v1.278 L<PPI> sometimes detects empty regexp as defined-or operator:

    ref // 1;
    foo // 1;

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
