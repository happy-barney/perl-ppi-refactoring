
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);
	use version;

	use PPI v1.278;
	use Ref::Util;
	use Scalar::Util;

	use PPIx::Augment::Utils qw (
		ppi_exclude
		ppi_include
	);

	use namespace::autoclean;

	sub Classify {
		my ($class, $element, @classification) = @_;

		my $identification = $Class->Identify ($element);

		$element = $identification->Augment ($element)
			if $identification
			&& ! (my $was_augmented = $element->isa ($identification))
			;

		my $is_classified = $element->classify (@classification);

		$element->diminish
			if $identification
			&& ! $was_augmented
			&& ! $element->document->isa (q (PPIx::Augment::Document))
			;

		return $is_classified;
	}

	sub classify {
		my ($self, @classifications) = @_;

		state $method_is_predicate = {
			isa => 1,
		};

		my @queue = map { [ $self, $_ ] } @classifications;
		while (@queue) {
			my ($value, $condition) = @{ shift @queue };

			unless (defined $value) {
				return ppix_exclude;
			}

			unless (defined $condition) {
				return ppi_exclude
					if Scalar::Util::blessed ($value)
					&& ! $value
					;

				next;
			}

			if (Ref::Util::is_coderef   ($condition)) {
				next
					if my $rv = $condition->($self, local $_ = $value)
					;

				# preserve ppix_exclude_all
				return $rv;
			}

			if (Ref::Util::is_arrayref  ($condition)) {
				unshift @queue, map { [ $value, $_ ] } @$condition;
				next;
			}

			if (Ref::Util::is_hashref   ($condition)) {
				return ppi_exclude
					unless Scalar::Util::blessed ($value)
					;

				for my $method (keys %$condition) {
					my $method_condition = $condition->{$method};

					return ppix_exclude
						if $method_is_predicate->{ $method }
						&& ! $value->$method ($method_condition)
						;

					my $code = $value->can ($method)
						// PPIx::Augment::Utils::->can ($method)
						// return ppix_exclude
						;

					unshift @queue, [ scalar $value->$code, $method_condition ];
				}

				next;
			}

			if (Ref::Util::is_regexpref ($condition)) {
				return ppix_exclude
					unless $value =~ $condition
					;
				next;
			}

			return ppix_exclude
				unless $value eq $condition
				;
		}

		return ppix_inclue;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 STATIC METHODS

=head2 Classify

    PPIx::Augment::DOM::Some::Class::->Classify ($element, @classifications);

Applies classification conditions to a C<$element>. If the C<$element> is not
already augmented, it will be temporarily augmented for the classification
process and then restored to its original state if the document wasn't
previously augmented.

L</Augments|/Augment> C<$element> and calls its L</classify> method.

L</Diminishes|diminish> the augmented C<$element> if it wasn't augmented
and if the element's document is not augmented.

=head1 METHODS

=head2 classify

    $augmented_element->classify (@classifications);

Returns L<ppi_exclude|PPIx::Augment::Utils/ppi_exclude> when any condition fails,
L<ppi_include|PPIx::Augment::Utils/ppi_include> otherwise.

Each classification operates on a C<current value> - initially the augmented
element itself. As conditions are evaluated, they may transform this C<current value>
(e.g., navigating to parent elements, extracting properties) for subsequent conditions to test.

Classification fails when the C<current value> is undefined.

Classification can be:

=over

=item undef

Condition pass.

=item non-ref scalar

String compare C<current value> with condition.

=item arrayref

List of conditions to be applied before the next classification.

=item coderef

Executes the provided coderef with C<$augmented_element> and C<current value> arguments
(C<current value> is also populated into C<$_>).

When the coderef returns a false value, classification fails.
L<ppi_exclude_all|PPIx::Augment::Utils/ppi_exclude_all> value is preserved.

	$coderef->($augmented_element, $current_value)

=item hashref

	{ key => $key_classification }

When C<key> is a predicate name, it is evaluated as:

	$current_value->$key ($key_classification)

Currently only C<isa> is treated as predicate.

Otherwise C<key> is treated as a scalar accessor, either the value of C<$value>
or L<PPIx::Augment::Utils> accessor.

The accessor provides a new C<current value> for C<$key_classification> evaluation.

=back

=head1 EXAMPLES

=head2 Classifications

=head3 classify PPI representation of keyword 'map'

	PPIx::Augment::DOM::Element::->Classify (
		$ppi_element,
		{ isa => q (PPI::Token::Word) },
		q (map)
	);

	PPIx::Augment::DOM::Element::->Classify (
		$ppi_element,
		where { it_is_token_word q (map) },
	);

	PPIx::Augment::DOM::Keyword::Map::->Classify (
		$ppi_element,
	);

	PPIx::Augment::DOM::Element::->Classify (
		$ppi_element,
		{
			isa => q (PPI::Token::Word),
			content => q (map),
		},
	);

=head2 classify element which is not last signigicant child

	PPIx::Augment::DOM::Element::->Classify (
		$ppi_element,
		{
			# undef condition means "snext_sibling" is defined and not C</no_element>
			snext_sibling => undef,
		},
	);

	PPIx::Augment::DOM::Element::->Classify (
		$ppi_element,
		{
			snext_sibling => { isa => q (PPI::Element) },
		},
	);

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and distributed under the same terms as the distribution itself.

=cut
