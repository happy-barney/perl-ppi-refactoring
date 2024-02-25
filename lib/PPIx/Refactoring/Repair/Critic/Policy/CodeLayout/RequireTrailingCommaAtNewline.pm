
use v5.14;
use warnings;

package PPIx::Refactoring::Repair::Critic::Policy::CodeLayout::RequireTrailingCommaAtNewline {
	use parent qw (PPIx::Refactoring::Repair::Critic::Policy);

	sub requires {
	}

	sub perl_critic {
		q (Perl::Critic::Policy::CodeLayout::RequireTrailingCommaAtNewline),
	}

	sub how_to_augment {
		my $insert_after;
		if (it_is_structure_list) {
		}

		if (it_is_structure_constructor) {
		}

		insert_after $insert_after, [ build_comma ];
	}
	}

	1;
}
