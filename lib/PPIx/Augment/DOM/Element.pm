
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent q (PPI::Element);

	use constant ppi_class => PPI::Element::;

	sub Classify {
		my ($class, $element, @classifications) = @_;
	}

	sub Identify {
		my ($class, $element) = @_;
	}

	sub Identify_Span {
		my ($class, $ppi_element) = @_;
	}

	sub child_index {
		my ($self) = @_;

		if ($self->parent) {
			my @children = $self->parent->children;
			for my $index (0 .. (@children - 1)) {
				return $index
					if $children[$index] == $self
					;
			}
		}

		return undef;
	}

	sub classify {
		my ($self, @classifications) = @_;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Element - Base class for augmented elements

=head1 INHERITANCE

    PPIx::Augment::DOM::Element
        isa PPI::Element

=head1 STATIC METHODS

=head2 Classify

    PPIx::Augment::DOM::...->Classify ($element, @classifications);

Identifies whether C<$element> represents class and if does,
whether it conforms to provided classification(s).

See also L</CLASSIFICATION SPECIFICATION>.

=head2 Identify

    PPIx::Augment::DOM::...->Identify ($element)

Method identifies whether C<$element> represents leading element
of structure represented by class (not always first).

=head2 Identify_Span

    my @indexes = PPIx::Augment::DOM::...->Identify_Span ($element);

Returns child indexes of C<$element>'s parent which represents given
augmented class.

Method should return empty list when C<$element> doesn't represent it.

=head1 METHODS

=head2 classify

    $element->classify (@classifications);

Identifies whether C<$element> conforms to provided classification(s).

See also L</CLASSIFICATION SPECIFICATION>.

=head2 ppi_class

    use constant ppi_class => ...;

    PPIx::Augment::DOM::...->ppi_class;

Name of L<PPI> class of leading element of structure represented by class.

=head1 CLASSIFICATION SPECIFICATION

Classification specification is data-structure describing conditions
given element must match.

=over

=item explicit C<undef>

Value is classified.

=item scalar value

Value is classified when its string representation equals to provided value.

=item regular expression

Value is classified when its string representation matches provided regular expression.

=item arrayref

Value is classified when it matches all classifications provided by arrayref.

=item coderef

Value is classified when provided coderef returns true.

Tested value is provided as second argument, so you can use C</where (&)>.

=item hashref

Value is classified when it matches all key-subspec pairs of hashref.

Key must be:

=over

=item literal C<isa>

Value must be instance of provided class.

=item L<PPIx::Augment::Utils> accessor name

Accessor is used to build new value and it must match C<subspec>.

=item method name of tested value

Method is used to build new value and it must match C<subspec>.

=back

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
