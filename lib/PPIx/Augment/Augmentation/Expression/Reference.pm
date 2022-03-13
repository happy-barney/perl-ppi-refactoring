
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Expression::Reference {
	use PPIx::Augment::Utils;

	use PPIx::Augment::Augmentation::Cast_Block;

	use PPIx::Augment::Expression::Lhs;
	use PPIx::Augment::Expression::Lhs::Invocant;

	sub _build_method_call {
		return unless it_is_operator_arrow;
		return unless it_is_method_call;

		PPIx::Augment::Expression::Call::Method::->new;
	}

	sub requires {
		my (undef, $document) = @_;

		&PPIx::Augment::Augmentation::Cast_Block::augment;
	}

	sub it_is_dereferenced {
		its_snext_sibling {
			it_is_operator_arrow
			|| it_is_structure_subscript
			|| it_is_structure_list
		}
	}

	sub lhs_augment_class {
		return PPIx::Augment::Expression::Lhs::Invocant::
			if its_snext_sibling { it_is_operator_arrow }
			&& its_snext_sibling { its_snext_sibling { it_is_method_call } }
			;
		return PPIx::Augment::Expression::Lhs::;
	}

	sub augment {
		my (undef, $document) = @_;

		&requires;

		ppix_transform $document
			=> where { its_parent { it_isnt_augmented_yet } }
			=> where { it_is_dereferenced }
			=> invoke {
				my $expression;

				$expression = undef
					// _build_call_method
					// _build_call_function
					// _build_subscripted
					;

				my $element = $_->sprevious_sibling;

				$expression->add_element ($element->clone);
				move_next_insignificant ($element, $expression);

				if (it_is_operator_arrow) {
					augment_element PPIx::Augment::Token::Operator::Arrow::;
					$expression->add_element ($element->clone);
					move_next_insignificant ($element, $expression);

					
				= PPIx::Augment::Expression::Cast_Block->new;
				$expression->add_element ($_->clone);

				move_next_insignificant ($_ => $expression);
				move_next_sibling       ($_ => $expression);

				current_replace ($expression);
			}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Expression::Reference - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Expression::Reference::augment ($unused, $ppi_document)

=head1 DESCRIPTION

Wraps referencing expressions as single PPI element: subscript, method call

	$foo{bar}
	$foo[bar]
	$foo(bar)
	$foo->{bar}
	$foo->[bar]
	$foo->(bar)
	$foo->bar

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
