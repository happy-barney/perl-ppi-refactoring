
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use PPIx::Augment::Internals::Exporter;

	use PPI v1.278;
	use Scalar::Util qw ();

	use PPIx::Augment::DOM::No_Element;

	sub current ();
	sub element;
	sub no_element ();

	sub current ()                        :Exported(accessor) {
		return $_;
	}

	sub element                           :Exported(accessor) {
		return current
			unless Scalar::Util::blessed ($_[0])
			;

		return shift
			if $_[0]->isa (PPI::Element::)
			;

		return shift
			if $_[0]->isa (PPIx::Augment::DOM::No_Element::)
			;

		return current;
	}

	sub no_element ()                     :Exported(accessor) {
		return PPIx::Augment::DOM::No_Element::->new;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils - PPI / PPIx::Augment document utilities

=head1 DESCRIPTION

Inspired by L<PPIx::Utils>, this module provides functions to make working
with L<PPI> and L<PPIx::Augment> documents easier (to both read and write).
It provides similar functions for features L<PPIx::Augment> introduces.

Unless specified otherwise, every function is exported by default.

Exportable tags:

=over

=item C<:all>

Exports all exportable functions.

=item C<:accessor>

Exports all L</ACCESSOR FUNCTIONS>.

=item C<:builder>

Exports all L</BUILDER FUNCTIONS>.

=item C<:classification>

Exports all L</CLASSIFICATION FUNCTIONS>.

=item C<:default>

Exports all functions exported by default.

=item C<:transformation>

Exports all L</TRANSFORMATION FUNCTIONS>.

=item C<:traversal>

Exports all L</TRAVERSAL FUNCTIONS>.

=back

=head1 GLOSSARY

=over

=item current element

Current element (stored in C<$_>) is safely populated by every function
which picks one element and operates on it.

=item effective element

The first argument of the function, if it is L</no element> or an instance of
L<PPI::Element>; otherwise, the L</current element>.

=item no element

A false value returned by an element accessor when there is no element to be returned.

The value is a blessed value that:

=over

=item evaluates as false

=item mimics L<PPI> / L<PPIx::Augment> element methods by returning safe false values

=back

The value is a blessed value that:

=over

=item evaluates to false

=item mimics PPI elements by returning safe false values

=back

Every function recognises L</no element> and acts properly.

=back

=head1 ACCESSOR FUNCTIONS

Helper functions to access various data from a L<PPI::Element> instance,
whether they are accessible via a direct method or have to be populated.

All accessor functions recognise C</no element> and return the corresponding value.

Unless specified otherwise, all functions work with L</effective element>.

=head2 current ()

Returns L</current element>.

=head2 element

Returns L</effective element>.

Assumed usage eg in classification function:

    sub my_classification {
        # Reminder: using this syntax, `element` will modify our arguments
        my $element = &element;
        my @other_arguments = @_;
        ...
    }

=head2 no_element ()

Returns value representing L</no element>.

=head1 BUILDER FUNCTIONS

Helper functions to construct new L<PPI> / L<PPIx::Augment> elements,
usually taking decomposed values and merging them into the corresponding element / node.

=head1 CLASSIFICATION FUNCTIONS

Helper functions to identify an instance of L<PPI::Element>.

Unless specified otherwise, all functions work with L</effective element>.

=head1 TRANSFORMATION FUNCTIONS

Helper functions to modify L</effective element>.

=head1 TRAVERSAL FUNCTIONS

Helper functions to navigate through documents / elements.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
