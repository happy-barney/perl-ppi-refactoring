
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use PPIx::Augment::Internals::Exporter;

	use PPI v1.278;
	use Ref::Util;
	use Scalar::Util qw ();

	use PPIx::Augment::DOM::No_Element;
	sub current ();
	sub element;
	sub no_element ();

	### ############################################################

	sub ppix_exclude ();
	sub ppix_exclude_all ();
	sub ppix_include ();

	### ############################################################

	sub current ()                      :Exported(accessor) {
		return $_;
	}

	sub element                         :Exported(accessor) {
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

	sub no_element ()                   :Exported(accessor) {
		return PPIx::Augment::DOM::No_Element::->new;
	}

	sub exclude_all (&)                 :Exported(classification) {
		my $code = shift;
		my $result = Ref::Util::is_plain_coderef ($code) ? $code->() : $code;

		return $result ? ppi_include : ppi_exclude_all;
	}

	sub ppix_exclude ()                 :Exported(classification) {
		return 1;
	}

	sub ppix_exclude_all ()             :Exported(classification) {
		return undef;
	}

	sub ppix_include ()                 :Exported(classification) {
		return 1;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils - PPI / PPIx::Augment processing utilities

=head1 DESCRIPTION

Inspired by L<PPIx::Utils>, this module provides functions to make working
with L<PPI> easier (both to write and read).
It also provides similar functions for features that L<PPIx::Augment> introduces.

All functions, unless specified otherwise, are exported by default.

All functions, unless specified otherwise, work with both L<PPI>
and L<PPIx::Augment> document models.

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

Exports all functions that are exported by default.

=item C<:transformation>

Exports all L</TRANSFORMATION FUNCTIONS>.

=item C<:traversal>

Exports all L</TRAVERSAL FUNCTIONS>.

=back

=head1 GLOSSARY

=over

=item current element

An element currently being processed by traversal functions, stored in C<$_>.

=item effective element

The first argument of the function, if it is L</no element> or an instance of
L<PPI::Element>; otherwise, the L</current element>.

=item no element

A false value returned by an element accessor when there is no element to be returned.
The value is compatible with L<PPI> (as an empty string).

The value is a blessed value that:

=over

=item evaluates to false

=item mimics PPI elements by returning safe false values

=back

See L</PPIx::Augment::DOM::No_Element> for more information.

=back

=head1 ACCESSOR FUNCTIONS

Helper functions to access various data from a L<PPI::Element> instance,
whether they are accessible via a direct method or have to be populated.

All accessor functions recognise C</no element> and return the corresponding value.

Unless specified otherwise, all functions work with the L</effective element>.

=head2 current ()

Returns L</current element>.

=head2 element

Returns L</effective element>.

Assumed usage eg in classification function:

    # Using this syntax so shift will actually modify our arguments
    my $element = &element;

=head2 no_element ()

Returns value representing L<PPI> meaning "there is no element".

=head1 BUILDER FUNCTIONS

Helper functions to construct new L<PPI> / L<PPIx::Augment> elements,
usually taking decomposed values and merging them into the corresponding element / node.

=head1 CLASSIFICATION FUNCTIONS

Helper functions to identify an instance of L<PPI::Element>.

Unless specified otherwise, all functions work with the L</effective element>.

Unless specified explicitly, classification functions do not return L<ppix_exclude_all>.
When you need such behaviour, you can use one of the following patterns:

	return classification || ppix_exclude_all;
	return exclude_all { classification };

=head2 exclude_all (&)

    exclude_all { ... }

Executes provided code as a classification and converts returned
L</ppix_exclude ()> to L</ppix_exclude_all ()>.

=head2 ppix_exclude ()

Handy named constant representing the value, which L<PPI> considers as
"exclude this element but continue with its children".

=head2 ppix_exclude_all ()

Handy named constant representing the value, which L<PPI> considers as
"exclude this element and all its children".

=head2 ppix_include ()

Handy named constant representing the value, which L<PPI> considers as
"include this element and continue with its children".

=head1 TRANSFORMATION FUNCTIONS

Helper functions to modify the L</effective element>.

=head1 TRAVERSAL FUNCTIONS

Helper functions to navigate through documents / elements.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
