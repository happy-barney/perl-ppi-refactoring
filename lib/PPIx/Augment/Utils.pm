
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use PPIx::Augment::Internals::Exporter;

	use PPI v1.278;
	use Ref::Util;
	use Scalar::Util qw ();

	use constant CLASS_INVOKE => q (PPIx::Augment::Utils::__::Invoke);
	use constant CLASS_WHERE  => q (PPIx::Augment::Utils::__::Where);

	use PPIx::Augment::DOM::No_Element;

	sub current ();
	sub element;
	sub invoke (&);
	sub it_is;
	sub no_element ();
	sub ppi_exclude ();
	sub ppi_exclude_all ();
	sub ppi_include ();
	sub where (&);

	sub _classification_condition {
		my ($context, $value, @conditions) = @_;

		while (@conditions) {
			my $condition = shift @conditions;

			if (Ref::Util::is_plain_arrayref ($condition)) {
				push @conditions, @$condition;
				next;
			}

			local @_ = ($context, $value, $condition);
			return ppi_exclude
				unless undef
				// &_classify_using_accessor
				// &_classify_using_content_compare
				// &_classify_using_content_match
				// &_classify_using_where
				;
		}

		return ppi_include;
	}

	sub _classification_conditions {
		my ($element, @conditions) = @_;

		return ppi_exclude
			unless $element
			;

		return _classification_condition (undef, $element, @conditions);
	}

	sub _classify_using_accessor {
		my ($context, $value, $condition) = @_;

		return
			unless Ref::Util::is_plain_hashref ($condition)
			;

		while (my ($method, $condition) = each %$condition) {
			return ppi_bool ($value->isa ($condition))
				if $method eq q (isa)
				;

			my $accessor = undef
				// __PACKAGE__->can ($method)
				// $value->can ($method)
				// return ppi_exclude
				;

			return ppi_exclude
				unless _classification_condition ($value, $accessor->($value), $condition)
				;
		}

		return ppi_include;
	}

	sub _classify_using_content_compare {
		my ($context, $value, $condition) = @_;

		return
			if ref $condition
			;

		return !! $value
			unless defined $condition
			;

		return $value eq $condition;
	}

	sub _classify_using_content_match {
		my ($context, $value, $condition) = @_;

		return
			unless Ref::Util::is_regexpref ($condition)
			;

		return !! scalar $value =~ $condition;
	}

	sub _classify_using_where {
		my ($context, $value, $condition) = @_;

		return
			unless Ref::Util::is_plain_coderef ($condition)
			;

		local $_ = $value;
		return !! $condition->($context, $value);
	}

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

	sub exclude_all (&)                   :Exported(classification) {
		my $code = $_[0];

		my $result = Ref::Util::is_coderef ($code)
			? $code->()
			: $code
			;

		return $result
			? ppi_include
			: ppi_exclude_all
			;
	}

	sub it_is                             :Exported(classification) {
		return _classification_conditions (
			&element,
			{ isa => shift },
			@_
		);
	}

	sub it_is_not (&)                     :Exported(classification) {
		my $code = $_[0];

		my $result = Ref::Util::is_coderef ($code)
			? $code->()
			: $code
			;

		return $result
			? ppi_exclude
			: ppi_include
			;
	}

	sub it_is_token_word                  :Exported(classification) {
		return it_is &element, PPI::Token::Word::, @_;
	}

	sub ppi_exclude ()                    :Exported(classification) {
		return 0;
	}

	sub ppi_exclude_all ()                :Exported(classification) {
		return undef;
	}

	sub ppi_include ()                    :Exported(classification) {
		return 1;
	}

	sub invoke (&)                        :Exported(traversal) {
		my ($code) = @_;

		return bless sub { local $_ = $_[1]; $code->(@_) }, CLASS_INVOKE;
	}

	sub where (&)                         :Exported(traversal) {
		my ($code) = @_;

		return bless sub { local $_ = $_[1]; $code->(@_) }, CLASS_WHERE;
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

Unless specified otherwise, all functions work with the L</effective element>.

Classification functions do not return L</ppix_exclude_all> unless specified otherwise.
When you need to return L</ppix_exclude_all ()> you can use one of following patterns:

    return classification || ppix_exclude_all;
    return exclude_all { classification };

=head2 exclude_all (&)

    exclude_all { ... }

Executes the provided code as a classification and converts the returned
L</ppi_exclude ()> to L</ppi_exclude_all ()>.

=head2 it_is

    it_is $element?, CLASS, @conditions?

Classify L</effective element> as an instance of C<CLASS>,
matching optional C<@conditions>.

=head3 it conditions

Before executing conditions sets

    current value   = effective element
    current context = undef

=over

=item undef

Evaluates as C<current value> in boolean context.

=item scalar

Stringwise compare C<current value> and condition value.

=item regexp

Match C<current value> and condition regexp/

=item coderef

Called as

    local $_ = current value;
    $coderef->(current context, $current value);

=item arrayref

Evaluates conditions using logical C<and> (and lazy evaluation)

=item hashref

Hashref key is treated either as one of PPI::Augment::Utils's functions
(if exists) or element's method (if exists).

    it_is $element, PPI::Token::Word:: {
        parent => [
            { isa  => PPI::Statement::Package:: },
            { name => qr ( ^ Test \b )x },
        ]
    }

Applies conditions as L</it conditions> with

    local current context = current value;
    local current value   = accessor (current value);

=back

=head2 it_is_not (&)

    it_is_not { ... }

Executes provided code as a classification and negates its return value,
returning L</ppi_include ()> or L</ppi_exclude ()>.

=head2 ppi_exclude ()

Handy named constant representing the value L<PPI> treats as
I<exclude this element but continue with its children>.

=head2 ppi_exclude_all ()

Handy named constant representing the value L<PPI> treats as
I<do not include this element and do not continue with its children>.

=head2 ppi_include ()

Handy named constant representing the value L<PPI> treats as
L<include this element and continue search with its children>.

=head1 TRANSFORMATION FUNCTIONS

Helper functions to modify the L</effective element>.

=head1 TRAVERSAL FUNCTIONS

Helper functions to navigate through documents / elements.

=head2 invoke (&)

	traversal_function $document
		=> where  { ... }
		=> where  { ... }
		=> invoke { ... your code ... }
		=> invoke { ... your code ... }
		;

Helper function registering code to be invoked when requested element is found.

When used multiple times, L</invoke (&)> block is executed in order of appearance
after all L</where (&)> blocks are executed.

L</invoke (&)> block, when executed,

=over

=item receives arguments as L<PPI>'s find functions

    $invoke_block->($document, $element);

=item has L</current element> populated with found element

=back

=head2 where (&)

	tranversal_function $document
		=> where { ... condition ... }
		=> where { ... condition ... }

Helper functions to pick documents / elements.

Returned value works with L<PPI>'s C<find> method as well.

L</where (&)> block should return

=over

=item L<ppi_include ()>

=item L</ppi_exclude ()>

=item L</ppi_exclude_all ()>

=back

When used multiple times,

=over

=item L</where (&)> blocks are executed before any L</invoke (&)> block

=item L</where (&)> blocks are executed in order of appearance

=item L</where (&)> blocks are combined using C<logical and> operator

=back

L</where (&)> block, when executed

=over

=item receives arguments as L<PPI>'s find functions

    $where_block->($document, $element);

=item has L</current element> populated with found element

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
