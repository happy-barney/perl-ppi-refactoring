
use v5.14;
use warnings;

package PPIx::Augment::DOM::Element {
	use parent qw (
		PPI::Element
	);

	use mro q (c3);

	use PPI v1.278;
	use Scalar::Util;

	use constant PPI_CLASS  => q (PPI::Element);
	use constant SUBCLASSES => (
		q (PPIx::Augment::DOM::Token),
		q (PPIx::Augment::DOM::Structure),
		q (PPIx::Augment::DOM::Statement),
	);

	sub Identify {
		my ($class, $element) = @_;

		return
			unless Scalar::Util::blessed ($element)
			&& $element->isa (q (PPI::Element))
			&& ! $element->isa (q (PPIx::Augment::DOM::Element))
			;

		if (my @subclasses = $class->SUBCLASSES) {
			for my $subclass (@subclasses) {
				return $subclass->Identify ($element) // next;
			}

			return;
		}

		return
			unless $element->isa ($class->PPI_CLASS)
			;

		return $class;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 CONSTANTS

=head2 PPI_CLASS

    package PPIx::Augment::DOM::Token::Number::Octal {
        use constant PPI_CLASS => q (PPI::Token::Number::Octal);
    }

=head2 SUBCLASSES

    package PPIx::Augment::DOM::Some::Construct {
        use constant SUBCLASSES => (
            q (PPIx::Augment::DOM::Some::Construct::Traditional),
            q (PPIx::Augment::DOM::Some::Construct::V534),
        );
    }

If the method returns a non-empty list, each element should be a class
that is a subclass of the defining class.

=head1 STATIC METHODS

=head2 Identify

    CLASS->Identify ($element);

Identifies whether the provided C<$element> is a leading element of a construct
described by C<CLASS> (or its subclasses defined in L</SUBCLASSES>).

When L</SUBCLASSES> returns a non-empty list, those classes will be investigated
(by calling their L</Identify> method).

Otherwise, it returns C<CLASS> when the given C<$element> is an instance of L</PPI_CLASS>,
or C<undef> when it is not.

Returns C<undef> when the C<$element> is already augmented or cannot be augmented.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and distributed under the same terms as the distribution itself.

=cut
