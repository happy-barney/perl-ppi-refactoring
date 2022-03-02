
use v5.16;
use warnings;

package PPIx::Augment::Expression::Call::Method {
	use parent qw[ PPI::Statement ];

	use HPB::PPIx::Utils qw[];

	sub new {
		my ($class, $arrow) = @_;

		my $self = $class->SUPER::new (my $clone = $arrow->clone);

		$self->{ppix_augment_arrow} = $clone;

		$self->_find_method ($arrow);
		$self->_find_invocant ($arrow);

		HPB::PPIx::Utils::replace_element $arrow, $self;

		return $self;
	}

	sub augment_element {
		my ($self, $element) = @_;

		PPIx::Augment::Token::Operator::Arrow->augment_element ($element);
	}

	sub _find_invocant {
		my ($self, $arrow) = @_;

		while (my $element = $arrow->previous_sibling) {
			my $is_significant = $element->significant;

			$self->first_element->__insert_before ($element->clone);
			$element->remove;

			last if $is_significant;
		}
	}

	sub _find_method {
		my ($self, $arrow) = @_;

		while (my $element = $arrow->next_sibling) {
			my $is_significant = $element->significant;

			$self->add_element ($element->clone);
			$element->remove;

			last if $is_significant;
		}
	}

	sub invocant {
		$_[0]->first_element;
	}

	sub method {
		$_[0]->last_element;
	}
}

1;
