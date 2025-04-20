
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::PPI::Defined_Or_Regex {

	use PPIx::Augment::Declare::Augmentation;
	use PPIx::Augment::Utils;

	use namespace::autoclean;

	declare augmentation
		=> where {
			it_is_operator_defined_or
			and its_sprevious_sibling {
				it_is_token_word
				and it_is_not {
					its_sprevious_sibling { it_is_token_operator q (->) }
				}
			}
		}
		=> invoke {
			elements_replace
				[ current ],
				[ build_token_regexp_match q (//) ]
		};

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::PPI::Defined_Or_Regex

=head1 SYNOPSIS

    require PPIx::Augment::Augmentation::PPI::Defined_Or_Regex;

    PPIx::Augment::->augment (
        $document,
        PPIx::Augment::Augmentation::PPI::Defined_Or_Regex::
    );

=head1 DESCRIPTION

As of v5.40, Perl treats the defined-or operator in the position of the first
function argument as an empty regexp without quoting operator.

    ref // 1;
    foo // 1;

As of v1.278, L<PPI> sometimes detects such an empty regexp as defined-or operator.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
