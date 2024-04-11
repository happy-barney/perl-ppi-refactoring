
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
	sub no_element ();
	sub ppi_bool ($);
	sub ppi_exclude ();
	sub ppi_exclude_all ();
	sub ppi_include ();

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

	sub it_is                           :Exported(classification) {
		return _classification_conditions (
			&element,
			{ isa => shift },
			@_
		);
	}

	sub it_is_not (&)                   :Exported(classification) {
		my $code = shift;
		my $result = Ref::Util::is_plain_coderef ($code) ? $code->() : $code;

		return $result ? ppi_exclude : ppi_include;
	}

	sub it_is_token_heredoc             :Exported(classification) {
		return it_is &element, PPI::Token::HereDoc::, @_;
	}

	sub it_is_token_label               :Exported(classification) {
		return it_is &element, PPI::Token::Label::, @_;
	}

	sub it_is_token_magic               :Exported(classification) {
		return it_is &element, PPI::Token::Magic::, @_;
	}

	sub it_is_token_number              :Exported(classification) {
		return it_is &element, PPI::Token::Number::, @_;
	}

	sub it_is_token_number_binary       :Exported(classification) {
		return it_is &element, PPI::Token::Number::Binary::, @_;
	}

	sub it_is_token_number_exp          :Exported(classification) {
		return it_is &element, PPI::Token::Number::Exp::, @_;
	}

	sub it_is_token_number_float        :Exported(classification) {
		return it_is &element, PPI::Token::Number::Float::, @_;
	}

	sub it_is_token_number_hex          :Exported(classification) {
		return it_is &element, PPI::Token::Number::Hex::, @_;
	}

	sub it_is_token_number_octal        :Exported(classification) {
		return it_is &element, PPI::Token::Number::Octal::, @_;
	}

	sub it_is_token_number_version      :Exported(classification) {
		return it_is &element, PPI::Token::Number::Version::, @_;
	}

	sub it_is_token_operator            :Exported(classification) {
		return it_is &element, PPI::Token::Operator::, @_;
	}

	sub it_is_token_pod                 :Exported(classification) {
		return it_is &element, PPI::Token::Pod::, @_;
	}

	sub it_is_token_prototype           :Exported(classification) {
		return it_is &element, PPI::Token::Prototype::, @_;
	}

	sub it_is_token_quote               :Exported(classification) {
		return it_is &element, PPI::Token::Quote::, @_;
	}

	sub it_is_token_quote_double        :Exported(classification) {
		return it_is &element, PPI::Token::Quote::Double::, @_;
	}

	sub it_is_token_quote_interpolate   :Exported(classification) {
		return it_is &element, PPI::Token::Quote::Interpolate::, @_;
	}

	sub it_is_token_quote_literal       :Exported(classification) {
		my $element = &element;

		return ppi_exclude
			if $element->DOES (PPI::Token::Prototype::)
			;

		return it_is $element, PPI::Token::Quote::Literal::, @_;
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

	sub ppi_bool ($)                    :Exported(classification) {
		return $_[0] ? ppi_include : ppi_exclude;
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

Executes provided code as a classification but negates its return value,
returning L</ppi_include ()> or L</ppi_exclude ()>.

=head2 it_is_token_heredoc

    it_is_token_heredoc $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::HereDoc>.

=head2 it_is_token_label

    it_is_token_label $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Label>.

=head2 it_is_token_magic

    it_is_token_magic $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Magic>.

=head2 it_is_token_number

    it_is_token_number $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number>.

=head2 it_is_token_number_binary

    it_is_token_number_binary $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number::Binary>.

=head2 it_is_token_number_exp

    it_is_token_number_exp $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number::Exp>.

=head2 it_is_token_number_float

    it_is_token_number_float $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number::Float>.

=head2 it_is_token_number_hex

    it_is_token_number_hex $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number::Hex>.

=head2 it_is_token_number_octal

    it_is_token_number_octal $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number::Octal>.

=head2 it_is_token_number_version

    it_is_token_number_version $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Number::Version>.

=head2 it_is_token_operator

    it_is_token_operator $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Operator>.

=head2 it_is_token_pod

    it_is_token_pod $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Pod>.

=head2 it_is_token_prototype

    it_is_token_prototype $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Prototype>.

=head2 it_is_token_quote

    it_is_token_quote $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Quote>.

=head2 it_is_token_quote_double

    it_is_token_quote_double $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Quote::Double>.

=head2 it_is_token_quote_interpolate

    it_is_token_quote_interpolate $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Quote::Interpolate>.

=head2 it_is_token_quote_literal

    it_is_token_quote_literal $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Quote::Literal>,
but also excluding L<PPI::Token::Prototype>.

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

    it_is_token_regexp_transliterate $element?, @it_conditions?

Shortcut for

    it_is $element?, PPI::Token::Regexp::Transliterate::, @it_conditions?

Matches instances of L<PPI::Token::Regexp::Transliterate>

    tr (...) (...);
    y  (...) (...);

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

Classify L</effective element> as L<PPI::Token::Word>.
See L</it_is> for description of C<@conditions>.

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
