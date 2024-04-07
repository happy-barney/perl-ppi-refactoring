
use v5.14;
use warnings;

package PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::ProhibitReverseSortBlock {
	use parent qw (PPIx::Refactoring::Repair::Critic::Policy);

	use PPIx::Augment::Utils;

	use namespace::clean;

	use constant critic_policy => q (Perl::Critic::Policy::BuiltinFunctions::ProhibitReverseSortBlock);

	sub how_to_augment {
		my ($self) = @_;

		invoke {
			insert_before [
				build_token_word (q (reverse)),
				build_token_whitespace (q ( )),
			];

			my $block = snext_sibling;
			ppix_transform snext_sibling
				=> where  { it_is_token_symbol { symbol => qr (^\$[ab]$) } }
				=> invoke {
					current->set_content (content eq q ($a) ? q ($b) : q ($a))
				}
				;
		};
	}

	1;
}
