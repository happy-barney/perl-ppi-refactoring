
use v5.16;
use warnings;

package PPIx::Augment::Expression::Method_Arguments {
	use parent qw[ PPIx::Augment::Rhs ];

	use PPIx::Augment::Utils (
		qw[ augment_snext_sibling ],
		qw[ it_is_expression_method_reference ],
		qw[ it_is_structure_list ],
	);

	use namespace::clean;

	sub augment {
		my ($class, $augment_from) = @_;

		return
			unless it_is_expression_method_reference ($augment_from);

		return
			unless it_is_structure_list ($augment_from->snext_sibling);

		return &augment_snext_sibling;
	}

	1;
}
