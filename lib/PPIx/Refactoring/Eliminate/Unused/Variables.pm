
use v5.14;
use warnings;

package PPIx::Refactoring::Eliminate::Unused::Variables {

	sub find {
		my ($self, $document) = @_;

		ppix_find $document
			=> where { it_is PPIx::Augment::Variable::Declared:: }
			;
	}

	sub requires {
		return +(
			PPIx::Augment::Augmentation::Variable::Declared::,
		)
	}

	1;
};

