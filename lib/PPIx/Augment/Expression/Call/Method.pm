
use v5.16;
use warnings;

package PPIx::Augment::Expression::Call::Method {
	use parent qw[ PPIx::Augment::Expression ];

	use HPB::PPIx::Utils qw[];
	use PPIx::Augment::Token::Operator::Arrow;

	sub new {
		my ($class, $arrow) = @_;

		my $self = $class->SUPER::new (my $clone = $arrow->clone);

		$self->arrow ($clone);

		$self->_find_method ($arrow);
		$self->_find_invocant ($arrow);

		HPB::PPIx::Utils::replace_element $arrow, $self;

		return $self;
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
