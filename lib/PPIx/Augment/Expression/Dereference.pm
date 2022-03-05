
use v5.16;
use warnings;

package PPIx::Augment::Expression::Dereference {
	use parent qw[ PPIx::Augment::Expression ];

	use PPIx::Augment::Expression::Lhs;
	use PPIx::Augment::Expression::Rhs;
	use PPIx::Augment::Expression::Call::Method;

	use HPB::PPIx::Utils (
		qw[ create_node ],
		qw[ is_method_call ],
		qw[ is_operator_arrow ],
		qw[ is_ppi_structure_subscript ],
		qw[ replace_element ],
	);

	use namespace::clean;

	sub _augment_build {
		my ($class, $lhs, @elements) = @_;

		my $self = &PPIx::Augment::Expression::_augment_build;

		while (my $subscript = $class->augment ($self->snext_sibling)) {
			$self = $subscript;
		}

		return $self;
	}

	sub _augment_build_from_subscript {
		my ($class, $augment_from) = @_;

		return $class->_augment_build (
			PPIx::Augment::Expression::Lhs->augment ($augment_from),
			PPIx::Augment::Expression::Rhs->augment ($augment_from->previous_sibling),
		);
	}

	sub _augment_build_from_arrow {
		my ($class, $augment_from) = @_;

		return $class->_augment_build (
			PPIx::Augment::Expression::Lhs->augment ($augment_from),
			PPIx::Augment::Token::Operator::Arrow->augment ($augment_from),
			PPIx::Augment::Expression::Rhs->augment ($augment_from),
		);
	}

	sub augment {
		my ($class, $augment_from) = @_;

		return &_augment_build_from_subscript
			if is_ppi_structure_subscript ($augment_from);

		return
			unless is_operator_arrow ($augment_from);

		#return PPIx::Augment::Expression::Call::Method->augment ($augment_from)
		#	if is_method_call ($augment_from->snext_sibling);

		return &_augment_build_from_arrow;
	}

	sub arrow {
		shift->_find_first_child (PPIx::Augment::Token::Operator::Arrow::);
	}

	sub lhs {
		shift->_find_first_child (PPIx::Augment::Expression::Lhs::);
	}

	sub rhs {
		shift->_find_first_child (PPIx::Augment::Expression::Rhs::);
	}

	1;
}
