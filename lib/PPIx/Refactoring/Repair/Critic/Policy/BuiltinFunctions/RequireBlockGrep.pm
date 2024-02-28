
use v5.14;
use warnings;

package PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::RequireBlockGrep {
	use parent qw (PPIx::Refactoring::Repair::Critic::Policy);

	use constant critic_policy => q (Perl::Critic::Policy::BuiltinFunctions::RequireBlockGrep);

	sub how_to_augment {
		my ($self) = @_;

		invoke {
			my $wrap_start = snext_sibling;
			my $comma      = ppix_search_next_sibling $wrap_start, where { it_is_comma };
			my @children   = children $wrap_start, sprevious_sibling ($comma);

			elements_replace
				[ @children ],
				[ build_structure_block (
					build_token_whitespace q ( ),
					@children,
					build_token_whitespace q ( ),
				) ],
				;

			if ($comma) {
				my $remove_start = next_sibling (sprevious_sibling ($comma));

				elements_remove
					[ children $remove_start, $comma ],
					;
			}
		};
	}

	1;
}
