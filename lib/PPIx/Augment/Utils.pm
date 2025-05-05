
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use PPIx::Augment::Internals::Exporter;

	use PPI v1.278;

	### ############################################################

	sub ppix_include;

	### ############################################################

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

False value returned by the element accessor when there is no such element.
The value is compatible with L<PPI> as an empty string.

The value supports all L<PPI::Element> / L<PPI::Node> methods.

See L</PPIx::Augment::DOM::No_Element> for more information.

=back

=head1 ACCESSOR FUNCTIONS

Helper functions to access various data from a L<PPI::Element> instance,
whether they are accessible via a direct method or have to be populated.

All accessor functions recognise C</no element> and return the corresponding value.

Unless specified otherwise, all functions work with the L</effective element>.

=head1 BUILDER FUNCTIONS

Helper functions to construct new L<PPI> / L<PPIx::Augment> elements,
usually taking decomposed values and merging them into the corresponding element / node.

=head1 CLASSIFICATION FUNCTIONS

Helper functions to identify an instance of L<PPI::Element>.

Unless specified otherwise, all functions work with the L</effective element>.

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
