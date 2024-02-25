
use v5.14;
use warnings;

package PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::ProhibitStringySplit {
	use parent qw (PPIx::Refactoring::Repair::Critic::Policy);

	use PPIx::Augment::Utils;

	use namespace::clean;

	use constant critic_policy => q (Perl::Critic::Policy::BuiltinFunctions::ProhibitStringySplit);

	sub how_to_augment {
		my ($self) = @_;

		invoke {
			its_snext_sibling {
				if (it_is_structure_list) {
					$_ = current->child (0)->first_element;
				}

				my $replacement = build_token qq (qr) . content;

				elements_replace [ current ], [ $replacement ];
			};
		};
	}

	1;
}
