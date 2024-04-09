
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use parent q (PPIx::Augment::Utils::Exporter);

	use PPI v1.278;
	use Scalar::Util qw ();

	use PPIx::Augment::No_Element;

	sub current ();
	sub element;
	sub no_element ();
	sub ppi_bool ($);
	sub ppi_exclude ();
	sub ppi_exclude_all ();
	sub ppi_include ();

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
			if $_[0]->isa (PPIx::Augment::No_Element::)
			;

		return current;
	}

	sub no_element ()                   :Exported(accessor) {
		return PPIx::Augment::No_Element::->new;
	}

	sub exclude_all (&)                 :Exported(classification) {
		my $code = shift;
		my $result = Ref::Util::is_plain_coderef ($code) ? $code->() : $code;

		return $result ? ppi_include : ppi_exclude_all;
	}

	sub it_is_not (&)                   :Exported(classification) {
		my $code = shift;
		my $result = Ref::Util::is_plain_coderef ($code) ? $code->() : $code;

		return $result ? ppi_exclude : ppi_include;
	}

	sub ppi_bool ($)                    :Exported(classification) {
		return shift ? ppi_include : ppi_exclude;
	}

	sub ppi_exclude ()                  :Exported(classification) {
		return 0;
	}

	sub ppi_exclude_all ()              :Exported(classification) {
		return undef;
	}

	sub ppi_include ()                  :Exported(classification) {
		return 1;
	}

	sub ppix_exclude ()                 :Exported(classification) {
		goto & ppi_exclude;
	}

	sub ppix_exclude_all ()             :Exported(classification) {
		goto & ppi_exclude_all;
	}

	sub ppix_include ()                 :Exported(classification) {
		goto & ppi_include;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils - PPI processing utils

=head1 DESCRIPTION

Inspired by L<PPIx::Utils> this module also provides functions to make work
with L<PPI> easier (to write and read). It also provides similar functions
for things L<PPIx::Augment> introduces.

Unless specified otherwise every function is exported by default.

Exportable tags

=over

=item C<:all>

Export all exportable functions

=item C<:accessor>

Exports all L</ACCESSOR FUNCTIONS>

=item C<:builder>

Exports all L</BUILDER FUNCTIONS>

=item C<:classification>

Exports all L</CLASSIFICATION FUNCTIONS>

=item C<:default>

Export all functions exported by default

=item C<:transformation>

Exports all L</TRANSFORMATION FUNCTIONS>

=item C<:traversal>

Exports all L</TRAVERSAL FUNCTIONS>

=back

=head1 GLOSSARY

=over

=item current element

An element currently processed by traversal functions, stored in <$_>.

=item effective element

First argument of function, if it is an instance of L<PPI::Element>,
L</current element> otherwise.

=item no element

False value return by element accessor when there is no such element.

Value is instance of class which

=over

=item evaluates as false

=item mimics PPI elements returning safe false values

=back

=back

=head1 ACCESSOR FUNCTIONS

Helper functions to access various data of L<PPI::Element> instance,
either whether they are accessible via direct method or have to be populated.

All accessor functions recognize C</no element> and return corresponding value.

Unless specified otherwise, all functions work with L</effective element>.

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
usually taking decomposed values and merge them into corresponding element / node.

=head1 CLASSIFICATION FUNCTIONS

Helper functions to identify instance of L<PPI::Element>.

Unless specified otherwise, all functions work with L</effective element>.

Classification functions do not return L</ppi_exclude_all>
unless specified otherwise.
When you need L</ppi_exclude_all ()> use one of patterns:

    return classification || ppi_exclude_all;
    return exclude_all { classification };

=head2 exclude_all (&)

    exclude_all { ... }

Executes provided code as a classification and converts returned value
L</ppi_exclude ()> to L</ppi_exclude_all ()>.

=head2 it_is_not (&)

    it_is_not { ... }

Executes provided code as a classification but negates its return value,
returning L</ppi_include ()> or L</ppi_exclude ()>.

=head2 ppi_bool ($)

    ppi_bool (boolean expression)

Converts boolean expression into L</ppi_include ()> / L</ppi_exclude ()>.

=head2 ppi_exclude ()

Handy named constant representing value L<PPI> considers as
I<do not include this element but continue with children>.

Evaluates as boolean false.

=head2 ppi_exclude_all ()

Handy named constant representing value L<PPI> considers as
I<do not include this element and do not continue with children>.

=head2 ppi_include ()

Handy named constant representing value L<PPI> considers as
L<include this element and continue search with children>.

=head2 ppix_exclude ()

Alias for L</ppi_exclude ()>

=head2 ppix_exclude_all ()

Alias for L</ppi_exclude_all ()>

=head2 ppix_include ()

Alias for L</ppi_include ()>

=head1 TRANSFORMATION FUNCTIONS

Helper functions to modify L</effective element>.

=head1 TRAVERSAL FUNCTIONS

Helper functions to navigate through documents / elements.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
