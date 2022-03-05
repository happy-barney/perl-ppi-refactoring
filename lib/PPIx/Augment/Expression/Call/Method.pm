
use v5.16;
use warnings;

package PPIx::Augment::Expression::Call::Method {
	use parent qw[ PPIx::Augment::Expression ];

	require PPIx::Augment::Expression::Invocant;
	require PPIx::Augment::Expression::Method_Arguments;
	require PPIx::Augment::Expression::Method_Reference;
	require PPIx::Augment::Token::Operator::Arrow;

	use HPB::PPIx::Utils (
		qw[ it_is_operator_arrow ],
	);

	use namespace::clean;

	sub augment {
		my ($class, $augment_from) = @_;

		# Expectation: $augment_from is an arrow operator
		return
			unless it_is_operator_arrow ($augment_from);

		my $invocant  = PPIx::Augment::Expression::Invocant->augment ($augment_from);
		my $method    = PPIx::Augment::Expression::Method_Reference->augment ($augment_from);
		my $arguments = PPIx::Augment::Expression::Method_Arguments->augment ($method);

		my $self = $class->_augment_build (
			grep $_, $invocant, $method, $arguments
		);
	}

	sub augmented_arrow {
		my ($self, $element) = @_;

		PPIx::Augment::Token::Operator::Arrow->new ('->');
	}

	sub _find_invocant {
		my ($self, $arrow) = @_;

		while (my $element = $arrow->previous_sibling) {
			my $is_significant = $element->significant;

			$self->first_element->__insert_before (my $clone = $element->clone);
			$element->remove;

			next unless $is_significant;
			$self->invocant ($clone);
			last;
		}
	}

	sub _find_method {
		my ($self, $arrow) = @_;

		while (my $element = $arrow->next_sibling) {
			my $is_significant = $element->significant;

			$self->add_element (my $clone = $element->clone);
			$element->remove;

			next unless $is_significant;
			$self->method ($clone);
			last;
		}
	}

	sub arrow {
		shift->_accessor (ppix_augment_arrow => @_);
	}

	sub invocant {
		shift->_accessor (ppix_augment_invocant => @_);
	}

	sub method {
		shift->_accessor (ppix_augment_method => @_);
	}
}

1;
