
use v5.14;
use warnings;

package PPIx::Refactoring::veure::ensure_import {
	sub refactoring {
		my ($context, $document, %params) = @_;

		undef
			// $context->refactor ('veure::extend-imports', %params)
			// $context->refactor ('veure::insert-import', %params)
			;
	}

	1;
}
