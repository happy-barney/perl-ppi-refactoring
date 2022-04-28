
use v5.14;
use warnings;

package PPIx::Refactoring::veure::move_signatures_after_attributes {
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub refactoring {
		my ($context, $document, @params) = @_;

		ppix_transform $document
			=> where { it_is_token_prototype }
			=> where { its_snext_sibling { it_is_operator_colon } }
			=> invoke {
				my @attributes = grep { it_is_token_attribute $_ } snext_siblings;

				my $following = next_sibling;
				my $last_attribute = $attributes[-1];

				do {
					my $previous = $following->previous_sibling;
					$previous->remove;
					element_insert_after $last_attribute, $previous;
				} while it_is_insignificant $following->previous_sibling;
			};
	}

	1;
}
