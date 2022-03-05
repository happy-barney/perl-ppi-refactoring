
use v5.16;
use warnings;

package PPIx::Augment::Expression::Method_Reference {
	use parent qw[ PPIx::Augment::Rhs ];

	sub augment {
		return &PPIx::Augment::Expression::_augment_snext_sibling;
	}

	1;
}
