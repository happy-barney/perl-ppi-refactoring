
use v5.14;
use warnings;

package PPIx::Refactoring::eliminate_cache_variable {
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub _symbols_of_interest {
		my ($expected) = @_;

		return ppi_false unless it_is_token_symbol;
		return ppi_false unless its_parent { it_is_statement_variable };
		return ppi_false unless its_sprevious_sibling { it_is_token_word qr/^(state|my)$/ };

		return its_snext_sibling {
			return ppi_false unless it_is_operator '=';
			return its_snext_sibling {
				return ppi_false unless it_is_token_word $expected;
				return ppi_false if its_snext_sibling { current && ! it_is_token_structure ';' };
				return ppi_true;
			};
		};
	}

	sub refactoring {
		my ($context, $document, $expression) = @_;

		my @variables = ppix_find $document,
			=> where { _symbols_of_interest $expression }
			;

		return unless @variables;

		for my $variable (reverse @variables) {
			for my $node (search_variable_scope $variable) {
				ppix_transform $node
					=> where { it_is_token_symbol $variable->content }
					=> invoke {
						current_replace (create_token_word $expression);
					};
			}
			element_remove_statement $variable->parent;
		}

		return 1;
	}

	1;
}
