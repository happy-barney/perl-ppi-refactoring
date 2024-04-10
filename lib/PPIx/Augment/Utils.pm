
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use parent q (PPIx::Augment::Utils::Exporter);

	use PPI v1.278;
	use Scalar::Util qw ();

	use PPIx::Augment::No_Element;

	sub current ();
	sub element;
	sub it_is;
	sub it_is_element;
	sub no_element ();
	sub ppi_exclude ();
	sub ppi_exclude_all ();
	sub ppi_include ();

	sub _classification_condition {
		my ($element, $method, $condition) = @_;

		return ppi_include
			unless defined $condition
			;

		return $element->isa ($condition)
			if $method eq q (isa)
			;

		$method = __PACKAGE__->can ($method)
			// $element->can ($method)
			// return ppi_exclude
			;

		my $value = $element->$method;

		return _classification_conditions ($value, $condition)
			if Ref::Util::is_plain_hashref ($condition)
			;

		return _compare_value ($value, $condition);
	}

	sub _classification_conditions {
		my ($element, @conditions) = @_;

		return ppi_exclude
			unless $element
			;

		while (my $condition = shift @conditions) {
			$condition = { content => $condition }
				unless Ref::Util::is_plain_hashref ($condition)
				;

			unshift @conditions, map +{ $_ => $condition->{$_ } }, keys %$condition
				and next
				if keys %$condition > 1
				;

			my ($method, $method_condition) = %$condition;

			unshift @conditions, map +{ $method => $_ }, @$method_condition
				and next
				if Ref::Util::is_plain_arrayref ($method_condition)
				;

			return ppi_exclude
				unless _classification_condition ($element, $method, $method_condition)
				;
		}

		return ppi_include;
	}

	sub _compare_value {
		my ($value, $condition) = @_;

		return 1
			unless defined $condition
			;

		return scalar $value =~ $condition
			if Ref::Util::is_regexpref ($condition)
			;

		return $condition->($value)
			if Ref::Util::is_coderef ($condition)
			;

		return $value eq $condition;
	}

	sub current ()                      :Exported(accessor) {
		return $_;
	}

	sub element                         :Exported(accessor) {
		return shift
			if Scalar::Util::blessed ($_[0])
			&& $_[0]->isa (PPI::Element::)
			;

		return current;
	}

	sub no_element ()                   :Exported(accessor) {
		return PPIx::Augment::No_Element::->new;
	}

	sub exclude_all (&)                 :Exported(classification) {
		my ($code) = @_;

		return $code->() || ppi_exclude_all;
	}

	sub it_is                           :Exported(classification) {
		return _classification_conditions (
			&element,
			{ isa => shift },
			@_
		);
	}

	sub it_is_element                   :Exported(classification) {
		return it_is &element, PPI::Element::, @_;
	}

	sub it_is_token_quote_single        :Exported(classification) {
		return it_is &element, PPI::Token::Quote::Single::, @_;
	}

	sub it_is_token_quotelike           :Exported(classification) {
		return it_is &element, PPI::Token::QuoteLike::, @_;
	}

	sub it_is_token_quotelike_backtick  :Exported(classification) {
		return it_is &element, PPI::Token::QuoteLike::Backtick::, @_;
	}

	sub it_is_token_quotelike_command   :Exported(classification) {
		return it_is &element, PPI::Token::QuoteLike::Command::, @_;
	}

	sub it_is_token_quotelike_readline  :Exported(classification) {
		return it_is &element, PPI::Token::QuoteLike::Readline::, @_;
	}

	sub it_is_token_quotelike_regexp    :Exported(classification) {
		return it_is &element, PPI::Token::QuoteLike::Regexp::, @_;
	}

	sub it_is_token_quotelike_words     :Exported(classification) {
		return it_is &element, PPI::Token::QuoteLike::Words::, @_;
	}

	sub it_is_token_regexp              :Exported(classification) {
		return it_is &element, PPI::Token::Regexp::, @_;
	}

	sub it_is_token_regexp_match        :Exported(classification) {
		return it_is &element, PPI::Token::Regexp::Match::, @_;
	}

	sub it_is_token_regexp_substitute   :Exported(classification) {
		return it_is &element, PPI::Token::Regexp::Substitute::, @_;
	}

	sub it_is_token_regexp_transliterate :Exported(classification) {
		return it_is &element, PPI::Token::Regexp::Transliterate::, @_;
	}

	sub it_is_token_separator           :Exported(classification) {
		return it_is &element, PPI::Token::Separator::, @_;
	}

	sub it_is_token_structure           :Exported(classification) {
		return it_is &element, PPI::Token::Structure::, @_;
	}

	sub it_is_token_symbol              :Exported(classification) {
		return it_is &element, PPI::Token::Symbol::, @_;
	}

	sub it_is_token_whitespace          :Exported(classification) {
		return it_is &element, PPI::Token::Whitespace::, @_;
	}

	sub it_is_token_word                :Exported(classification) {
		return it_is &element, PPI::Token::Word::, @_;
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

Executes provided code as classification but converts L</ppi_exclude ()>
to L</ppi_exclude_all ()>.

=head2 it_is

    it_is $element?, $CLASS, @conditions?

    it_is (PPI::Token::, ...);
    it_is ($element, PPI::Token::, ...);

Classify L</effective element> as an instance of C<$CLASS> matching
optional C<@conditions>.

Condition types:

=over

=item undef

Treated as "condition doesn't exist" (ie, returns L</ppi_include ()>).

=item scalar

Compares stringwise element's content with given value.

=item regexp

Applies regexp on element's content.

=item coderef

Calls it with element's content as a single argument.

=item arrayref

Applies every condition in array (merged using C<and>).

=item hashref

Hashref key is treated either as one of PPI::Augment::Utils's functions
(if exists) or element's method (if exists).

Each key-value pair is evaluated is condition applied on return value of
function/method represented by key.

    { parent => [
        { isa => PPI::Statement::Package:: },
        { name => qr ( ^ Test )x },
    }

=back

=head2 it_is_element

    it_is_element $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Element>.

=head2 it_is_token_quote_single

    it_is_token_quote_single $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Quote::Single>.

=head2 it_is_token_quotelike

    it_is_token_quotelike $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::QuoteLike>.

=head2 it_is_token_quotelike_backtick

    it_is_token_quotelike_regex $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::QuoteLike::Backtick>.

=head2 it_is_token_quotelike_command

    it_is_token_quotelike_regex $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::QuoteLike::Command>.

=head2 it_is_token_quotelike_readline

    it_is_token_quotelike_regex $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::QuoteLike::Readline>.

=head2 it_is_token_quotelike_regexp

    it_is_token_quotelike_regex $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::QuoteLike::Regexp>.

=head2 it_is_token_quotelike_words

    it_is_token_quotelike_words $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::QuoteLike::Words>.

=head2 it_is_token_regexp

=head2 it_is_token_regexp_match

    it_is_token_regexp_match $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Regexp::Match>.

=head2 it_is_token_regexp_substitute

    it_is_token_regexp_substitute $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Regexp::Substitute>.

=head2 it_is_token_regexp_transliterate

    it_is_token_regexp_transliterate $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Regexp::Transliterate>.

=head2 it_is_token_separator

    it_is_token_separator $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Separator>.

=head2 it_is_token_structure

    it_is_token_structure $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Structure>.

=head2 it_is_token_symbol

    it_is_token_symbol $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Symbol>.

=head2 it_is_token_whitespace

    it_is_token_whitespace $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Whitespace>.

=head2 it_is_token_word

    it_is_token_word $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Word>.

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
