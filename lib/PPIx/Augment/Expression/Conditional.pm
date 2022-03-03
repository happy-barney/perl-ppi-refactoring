
use v5.16;
use warnings;

package PPIx::Augment::Expression::Conditional {
	use parent qw[ PPIx::Augment::Expression ];

	sub new {
		my ($class, $question_mark) = @_;

		my $self = $class->SUPER::new (
			my $clone = $question_mark->clone
		);

		$self->question_mark ($clone);

		$self->_find_condition ($question_mark);
		$self->_find_then_expression ($question_mark);
		$self->_find_else_expression ($question_mark);

		HPB::PPIx::Utils::replace_element $question_mark, $self;

		return $self;
	}

	sub _find_condition {
		my ($self, $question_mark) = @_;

		while (my $element = $question_mark->previous_sibling) {
			my $is_significant = $element->significant;

			$self->first_element->__insert_before (my $clone = $element->clone);
			$element->remove;

			next unless $is_significant;

			$self->condition ($clone);
			last;
		}
	}

	sub _find_then_expression {
		my ($self, $question_mark) = @_;

		while (my $element = $question_mark->next_sibling) {
			my $is_significant = $element->significant;

			$self->add_element (my $clone = $element->clone);
			$element->remove;

			next unless $is_significant;
			$self->then_expression ($clone);
			last;
		}
	}

	sub _find_else_expression {
		my ($self, $question_mark) = @_;

		while (my $element = $question_mark->next_sibling) {
			my $is_significant = $element->significant;

			$self->add_element (my $clone = $element->clone);
			$element->remove;

			next unless $is_significant;
			$self->colon ($clone);
			last;
		}

		while (my $element = $question_mark->next_sibling) {
			my $is_significant = $element->significant;

			$self->add_element (my $clone = $element->clone);
			$element->remove;

			next unless $is_significant;
			$self->else_expression ($clone);
			last;
		}
	}

	sub condition {
		shift->_accessor (ppix_augment_cond => @_);
	}

	sub else_expression {
		shift->_accessor (ppix_augment_else => @_);
	}

	sub then_expression{
		shift->_accessor (ppix_augment_then => @_);
	}

	sub question_mark {
		shift->_accessor (ppix_augment_question_mark => @_);
	}

	sub colon {
		shift->_accessor (ppix_augment_colon => @_);
	}

	1;
}
