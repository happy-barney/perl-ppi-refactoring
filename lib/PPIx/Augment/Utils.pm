
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
	sub it_is_node;
	sub no_element ();
	sub ppi_bool ($);
	sub ppi_exclude ();
	sub ppi_exclude_all ();
	sub ppi_include ();

	sub _accessor_children {
		my ($method, $element, $first, $last) = @_;

		return
			unless it_is_node $element
			;

		my @all = $element->$method;

		$first = _array_index (scalar @all, $first // 0);
		$last  = _array_index (scalar @all, $last // -1);

		$first = $last
			if $first > $last
			;

		my @children = @all[$first .. $last];

		return wantarray
			? @children
			: \ @children
			;
	}

	sub _accessor_list {
		my ($method, $element, @args) = @_;

		return unless $element;
		return unless $element->can ($method);
		return $element->$method (@args);
	}

	sub _accessor_list_node {
		my ($method, $element, @args) = @_;

		return unless it_is_node $element;
		return $element->$method (@args);
	}

	sub _accessor_scalar {
		return scalar &_accessor_list;
	}

	sub _accessor_scalar_node {
		return scalar &_accessor_list_node;
	}

	sub _array_index {
		my ($count, $value) = @_;

		$value = -1 unless $value < $count;
		$value += $count if $value < 0;
		$value = 0 if $value < 0;

		return $value;
	}

	sub _build_element {
		my ($class, @children) = @_;
		my @constructor = Ref::Util::is_plain_arrayref ($children[0])
			? @{ shift @children }
			: ()
			;

		@constructor = grep defined, @constructor;
		if ($class->isa (PPI::Token::)) {
			return undef
				unless @constructor = grep length, @constructor
				;
		}

		my $element = $class->new (@constructor)
			// return undef
			;

		if ($class->isa (PPI::Node::)) {
			for my $child (@children) {
				next unless it_is_element ($child);

				$element->add_element ($child->clone);
			}
		}

		return $element;
	}

	sub _build_token {
		my @class_map;
		push @class_map, shift
			while ref $_[0]
			;

		my $content = shift;

		return undef unless defined $content;
		return undef unless length $content;

		for my $map_entry (@class_map) {
			unless (Ref::Util::is_plain_hashref ($map_entry)) {
				return undef
					unless _classification_condition (undef, $content, $map_entry)
					;
				next;
			}

			for my $class (keys %$map_entry) {
				next unless $class->isa (PPI::Token::);
				next unless _classification_condition (undef, $content, $map_entry->{$class});
				return $class->new ($content);
			}
		}

		return undef;
	}

	sub _build_token_quoted {
		my ($class, $re_validate, $content) = @_;

		return
			unless defined $content
			&& defined $re_validate
			&& $content =~ m (^($re_validate))x
			;

		my $init = $1;
		my $token = $class->new ($init)
			// return no_element
			;

		$class->_fill (bless {
			class       => $class,
			line        => $content,
			line_cursor => length $init,
			line_length => length $content,
			token       => $token,
		}, PPI::Tokenizer::);

		return $token;
	}

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

	sub _element_key {
		return & Scalar::Util::refaddr;
	}

	sub _link_parent_child {
		my ($parent, $child) = @_;
		Scalar::Util::weaken ($PPI::Singletons::_PARENT{_element_key $child} = $parent);
	}

	sub child                           :Exported(accessor) {
		return _accessor_scalar_node (child => &element, @_) || no_element;
	}

	sub children                        :Exported(accessor) {
		return _accessor_children children => &element, @_;
	}

	sub content                         :Exported(accessor) {
		return _accessor_scalar (content => &element) // q ();
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

	sub first_child                     :Exported(accessor) {
		return _accessor_scalar_node (child => &element, 0) || no_element;
	}

	sub first_token                     :Exported(accessor) {
		return eval { _accessor_scalar (first_token => &element) } || no_element;
	}

	sub last_child                      :Exported(accessor) {
		return _accessor_scalar_node (child => &element, -1) || no_element;
	}

	sub last_token                      :Exported(accessor) {
		return eval { _accessor_scalar (last_token => &element) } || no_element;
	}

	sub next_sibling                    :Exported(accessor) {
		return _accessor_scalar (next_sibling => &element) || no_element;
	}

	sub next_token                      :Exported(accessor) {
		return _accessor_scalar (next_token => &element) || no_element;
	}

	sub no_element ()                   :Exported(accessor) {
		return PPIx::Augment::No_Element::->new;
	}

	sub parent                          :Exported(accessor) {
		return _accessor_scalar (parent => &element) || no_element;
	}

	sub previous_sibling                :Exported(accessor) {
		return _accessor_scalar (previous_sibling => &element) || no_element;
	}

	sub previous_token                  :Exported(accessor) {
		return _accessor_scalar (previous_token => &element) || no_element;
	}

	sub schild                          :Exported(accessor) {
		return _accessor_scalar_node (schild => &element, @_) || no_element;
	}

	sub schildren                       :Exported(accessor) {
		return _accessor_children (schildren => &element, @_);
	}

	sub snext_sibling                   :Exported(accessor) {
		return _accessor_scalar (snext_sibling => &element) || no_element;
	}

	sub sprevious_sibling               :Exported(accessor) {
		return _accessor_scalar (sprevious_sibling => &element) || no_element;
	}

	sub top_element                     :Exported(accessor) {
		return _accessor_scalar (top => &element) || no_element;
	}

	sub build_token_number_octal ($)    :Exported(builder) {
		return _build_token
			{ PPI::Token::Number::Octal:: => qr (^ [-]? 0 [oO]? (?= _* [0-7]) [0-7_]+ $)x },
			@_
	}

	sub build_token_number_version ($)  :Exported(builder) {
		return _build_token
			{ PPI::Token::Number::Version:: => qr (^ v \d)x },
			@_
	}

	sub build_token_operator ($)        :Exported(builder) {
		return _build_token
			{ PPI::Token::Operator:: => sub { exists $PPI::Singletons::OPERATOR{$_} } },
			@_
	}

	sub build_token_prototype ($)       :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Prototype::,
			qr <[(]>,
			@_
		);
	}

	sub build_token_quote_double ($)    :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Quote::Double::,
			qr (^["]),
			@_
		);
	}

	sub build_token_quote_interpolate ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Quote::Interpolate::,
			qr (^qq\b),
			@_
		);
	}

	sub build_token_quote_literal ($)   :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Quote::Literal::,
			qr (^q\b),
			@_
		);
	}

	sub build_token_quote_single ($)    :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Quote::Single::,
			qr (^[']),
			@_
		);
	}

	sub build_token_quotelike_backtick ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::QuoteLike::Backtick::,
			qr (^[`]),
			@_
		);
	}

	sub build_token_quotelike_command ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::QuoteLike::Command::,
			qr (^qx),
			@_
		);
	}

	sub build_token_quotelike_readline ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::QuoteLike::Readline::,
			qr (^<),
			@_
		);
	}

	sub build_token_quotelike_regexp ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::QuoteLike::Regexp::,
			qr (^qr),
			@_
		);
	}

	sub build_token_quotelike_words ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::QuoteLike::Words::,
			qr (^qw),
			@_
		);
	}

	sub build_token_regexp_match ($)    :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Regexp::Match::,
			qr (^[m/]),
			@_
		);
	}

	sub build_token_regexp_substitute ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Regexp::Substitute::,
			qr (^s),
			@_
		);
	}

	sub build_token_regexp_transliterate ($) :Exported(builder) {
		return _build_token_quoted (
			PPI::Token::Regexp::Transliterate::,
			qr (^ (?: (?:tr) | (?:y) ) )x,
			@_
		);
	}

	sub build_token_structure ($)       :Exported(builder) {
		state $token_structure = [ qw < ( ) { } [ ] ; > ];
		return _build_token
			{ PPI::Token::Structure:: => sub { scalar grep { $_[1] eq $_ } @$token_structure } },
			@_
	}

	sub build_token_whitespace ($)      :Exported(builder) {
		return _build_token
			{ PPI::Token::Whitespace:: => qr (^\s+$) },
			@_
	}

	sub build_token_word ($)            :Exported(builder) {
		return _build_token
			{ PPI::Token::Word:: => qr (^ (?! \d) \w+ $)x },
			@_
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

	sub it_is_document                  :Exported(classification) {
		return it_is &element, PPI::Document::, @_;
	}

	sub it_is_element                   :Exported(classification) {
		return it_is &element, PPI::Element::, @_;
	}

	sub it_is_node                      :Exported(classification) {
		return it_is &element, PPI::Node::, @_;
	}

	sub it_is_not (&)                   :Exported(classification) {
		my $code = shift;
		my $result = Ref::Util::is_plain_coderef ($code) ? $code->() : $code;

		return $result ? ppi_exclude : ppi_include;
	}

	sub it_is_significant               :Exported(classification) {
		return it_is &element, PPI::Element::, { significant => undef };
	}

	sub it_is_statement                 :Exported(classification) {
		return it_is &element, PPI::Statement::, @_;
	}

	sub it_is_statement_break           :Exported(classification) {
		return it_is &element, PPI::Statement::Break::, @_;
	}

	sub it_is_statement_compound        :Exported(classification) {
		return it_is &element, PPI::Statement::Compound::, @_;
	}

	sub it_is_statement_data            :Exported(classification) {
		return it_is &element, PPI::Statement::Data::, @_;
	}

	sub it_is_statement_end             :Exported(classification) {
		return it_is &element, PPI::Statement::End::, @_;
	}

	sub it_is_statement_expression      :Exported(classification) {
		return it_is &element, PPI::Statement::Expression::, @_;
	}

	sub it_is_statement_given           :Exported(classification) {
		return it_is &element, PPI::Statement::Given::, @_;
	}

	sub it_is_statement_include         :Exported(classification) {
		return it_is &element, PPI::Statement::Include::, @_;
	}

	sub it_is_statement_null            :Exported(classification) {
		return it_is &element, PPI::Statement::Null::, @_;
	}

	sub it_is_statement_package         :Exported(classification) {
		return it_is &element, PPI::Statement::Package::, @_;
	}

	sub it_is_statement_scheduled       :Exported(classification) {
		return it_is &element, PPI::Statement::Scheduled::, @_;
	}

	sub it_is_statement_sub             :Exported(classification) {
		return it_is &element, PPI::Statement::Sub::, @_;
	}

	sub it_is_statement_variable        :Exported(classification) {
		return it_is &element, PPI::Statement::Variable::, @_;
	}

	sub it_is_statement_when            :Exported(classification) {
		return it_is &element, PPI::Statement::When::, @_;
	}

	sub it_is_structure_block           :Exported(classification) {
		return it_is &element, PPI::Structure::Block::, @_;
	}

	sub it_is_structure_condition       :Exported(classification) {
		return it_is &element, PPI::Structure::Condition::, @_;
	}

	sub it_is_structure_constructor     :Exported(classification) {
		return it_is &element, PPI::Structure::Constructor::, @_;
	}

	sub it_is_structure_for             :Exported(classification) {
		return it_is &element, PPI::Structure::For::, @_;
	}

	sub it_is_structure_given           :Exported(classification) {
		return it_is &element, PPI::Structure::Given::, @_;
	}

	sub it_is_structure_list            :Exported(classification) {
		return it_is &element, PPI::Structure::List::, @_;
	}

	sub it_is_structure_subscript       :Exported(classification) {
		return it_is &element, PPI::Structure::Subscript::, @_;
	}

	sub it_is_structure_when            :Exported(classification) {
		return it_is &element, PPI::Structure::When::, @_;
	}

	sub it_is_token                     :Exported(classification) {
		return it_is &element, PPI::Token::, @_;
	}

	sub it_is_token_array_index         :Exported(classification) {
		return it_is &element, PPI::Token::ArrayIndex::, @_;
	}

	sub it_is_token_attribute           :Exported(classification) {
		return it_is &element, PPI::Token::Attribute::, @_;
	}

	sub it_is_token_cast                :Exported(classification) {
		return it_is &element, PPI::Token::Cast::, @_;
	}

	sub it_is_token_comment             :Exported(classification) {
		return it_is &element, PPI::Token::Comment::, @_;
	}

	sub it_is_token_data                :Exported(classification) {
		return it_is &element, PPI::Token::Data::, @_;
	}

	sub it_is_token_end                 :Exported(classification) {
		return it_is &element, PPI::Token::End::, @_;
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

=head2 child

    child 1;
    child $node, -1;

Returns child of L</effective element> if possible,
L</no element> otherwise.

=head2 children

    children;
    children 0, -1;
    children -3, -2;
    children $element;

Returns C<content> of L</effective element>, empty list otherwise.

If called with additional numeric arguments, first is treated as index
of first child to return, second (-1 unless specified) as index of last
child to return.

Both can be negative.

=head2 content

    content;
    content $element;

Returns C<content> of L</effective element>, empty string otherwise.

=head2 current ()

Returns L</current element>.

=head2 element

Returns L</effective element>.

Assumed usage eg in classification function:

    # Using this syntax so shift will actually modify our arguments
    my $element = &element;

=head2 first_child

    first_element;
    first_element $node;

Returns C<first_element> of L</effective element> if possible,
L<no_element> otherwise.

=head2 first_token

    first_token;
    first_token $element;

Returns C<first_token> of L</effective element> if possible,
L<no_element> otherwise.

=head2 last_child

    last_child;
    last_child $node;

Returns last child of L</effective element> if possible,
L<no_element> otherwise.

=head2 last_token

    last_token;
    last_token $element;

Returns C<last_token> of L</effective element> if possible,

=head2 next_sibling

    next_sibling;
    next_sibling $element;

Returns next sibling of L</effective element> if possible,
L</no element> otherwise.

=head2 next_token

    next_token;
    next_token $element;

Returns next token of L</effective element> if possible,
L</no element> otherwise.

=head2 no_element ()

Returns value representing L<PPI> meaning "there is no element".

=head2 parent

    parent;
    parent $element;

Returns parent element of L</effective element> if possible,
L</no element> otherwise.

=head2 previous_sibling

    previous_sibling;
    previous_sibling $element;

Returns previous sibling of L</effective element> if possible,
L</no element> otherwise.

=head2 previous_token

    previous_token;
    previous_token $element;

Returns previous token of L</effective element> if possible,
L</no element> otherwise.

=head2 schild

    schild 1;
    schild $node, -1;

Returns significant child of L</effective element> if possible,
L</no element> otherwise.

=head2 schildren

    schildren;
    schildren 0, -1;
    schildren -3, -2;
    schildren $element;

Returns significant C<children> of L</effective element> if possible,
empty list otherwise.

When called with additional numeric arguments, first is treated as index
of first child to return, second (-1 unless specified) as index of last
child to return.

When called in scalar context, it returns corresponding arrayref
(unlike raw L<PPI::Node> method)

=head2 snext_sibling

    snext_sibling;
    snext_sibling $element;

Returns next significant sibling of L</effective element> if possible,
L</no element> otherwise.

=head2 sprevious_sibling

    sprevious_sibling;
    sprevious_sibling $element;

Returns previous significant sibling of L</effective element> if possible,
L</no element> otherwise.

=head2 top_element

    top_element;
    top_element $element;

Returns top element (one without parent) of L</effective element>
if possible, L</no_element ()> otherwise.

=head1 BUILDER FUNCTIONS

Helper functions to construct new L<PPI> / L<PPIx::Augment> elements,
usually taking decomposed values and merge them into corresponding element / node.

=head2 build_token_number_octal ($)

    build_token_number_octal (q (0123));

Builds instance of L<PPI::Token::Number::Octal>.

=head2 build_token_number_version ($)

    build_token_number_version q (v5.14);

=head2 build_token_operator ($)

    build_token_operator q (->);

Builds instance of L<PPI::Token::Operator>.

=head2 build_token_prototype ($)

    build_token_prototype q (($))

Returns instance of L<PPI::Token::Prototype> from given string.

=head2 build_token_quote_double ($)

    build_token_quote_double q ("foo")

Returns element representing provided string. Element is an instance of
L<PPI::Token::Quote::Double>.

=head2 build_token_quote_interpolate ($)

    build_token_quote_interpolate q (qq (foo))

Returns element representing provided string. Element is an instance of
L<PPI::Token::Quote::Interpolate>.

=head2 build_token_quote_literal ($)

    build_token_quote_literal q (q (foo))

Returns element representing provided string. Element is an instance of
L<PPI::Token::Quote::Literal>.

=head2 build_token_quote_single ($)

    build_token_quote_single q ('foo')

Returns element representing provided string. Element is an instance of
L<PPI::Token::Quote::Single>.

=head2 build_token_quotelike_backtick ($)

    build_token_quotelike_backtick q (`foo`)

Returns element representing provided string. Element is an instance of
L<PPI::Token::QuoteLike::Backtick>.

=head2 build_token_quotelike_command ($)

    build_token_quotelike_command q (qx (foo bar))

Returns element representing provided string. Element is an instance of
L<PPI::Token::QuoteLike::Command>.

=head2 build_token_quotelike_readline ($)

    build_token_quotelike_readline q (<abc>)

Returns element representing provided string. Element is an instance of
L<PPI::Token::QuoteLike::Readline>.

=head2 build_token_quotelike_regexp ($)

    build_token_quotelike_regexp q (qr (abc))

Returns element representing provided string. Element is an instance of
L<PPI::Token::QuoteLike::Regexp>.

=head2 build_token_quotelike_words ($)

    build_token_quotelike_words q (qw (abc ABC))

Returns element representing provided string. Element is an instance of
L<PPI::Token::QuoteLike::Words>.

=head2 build_token_regexp_match ($)

    build_token_regexp_match q (m (abc))

Returns element representing provided string. Element is an instance of
L<PPI::Token::Regexp::Match>.

=head2 build_token_regexp_substitute ($)

    build_token_regexp_substitute q (s (abc) (ABC)gr)

Returns element representing provided string. Element is an instance of
L<PPI::Token::Regexp::Substitute>.

=head2 build_token_regexp_transliterate ($)

    build_token_regexp_transliterate q (tr [abc] [ABC]r)

Returns element representing provided string. Element is an instance of
L<PPI::Token::Regexp::Transliterate>.

=head2 build_token_structure ($)

    build_token_structure q ( );

Builds instance of L<PPI::Token::Structure>.

=head2 build_token_whitespace ($)

    build_token_whitespace q ( );

Builds instance of L<PPI::Token::Whitespace>.

=head2 build_token_word ($)

    build_token_word q (foo);

Builds instance of L<PPI::Token::Word>.

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

=head2 it_is_document

    it_is_document $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Document>.

=head2 it_is_element

    it_is_element $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Element>.

=head2 it_is_node

    it_is_node $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Node>.

=head2 it_is_not (&)

    it_is_not { ... }

Executes provided code as a classification but negates its return value,
returning L</ppi_include ()> or L</ppi_exclude ()>.
FEatu

=head2 it_is_significant

    it_is_significant $element?, @conditions?;

Shortcut for calling L</it_is_element> with additional condition
to check whether element is significant.

=head2 it_is_statement

    it_is_statement $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement>.

=head2 it_is_statement_break

    it_is_statement_break $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Break>.

=head2 it_is_statement_compound

    it_is_statement_compound $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Compound>.

=head2 it_is_statement_data

    it_is_statement_data $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Data>.

=head2 it_is_statement_end

    it_is_statement_end $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::End>.

=head2 it_is_statement_expression

    it_is_statement_expression $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Expression>.

=head2 it_is_statement_given

    it_is_statement_given $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Given>.

=head2 it_is_statement_include

    it_is_statement_include $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Include>.

=head2 it_is_statement_null

    it_is_statement_null $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Null>.

=head2 it_is_statement_package

    it_is_statement_package $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Package>.

Matches

    package Foo;
    package Foo { ... }

=head2 it_is_statement_scheduled

    it_is_statement_scheduled $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Scheduled>.

Matches

    BEGIN { ... }
    CHECK { ... }
    UNITCHECK { ... }
    INIT { ... }
    END { ... }

=head2 it_is_statement_sub

    it_is_statement_sub $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::Sub>.

=head2 it_is_statement_variable

Shortcut for calling L</it_is> with L<PPI::Statement::When>.

Matches for example:

    my $foo;
    my $foo = 1;
    our ($foo, $bar);
    local $foo;
    state $foo;

=head2 it_is_statement_when

    it_is_statement_when $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Statement::When>.

Matches

    when (...) { ... }
    default { ... }

=head2 it_is_structure_block

    it_is_structure_block $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::Block>.

=head2 it_is_structure_condition

    it_is_structure_condition $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::Condition>.

=head2 it_is_structure_constructor

    it_is_structure_constructor $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::Constructor>.

=head2 it_is_structure_for

    it_is_structure_for $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::For>.

=head2 it_is_structure_given

    it_is_structure_given $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::Given>.

=head2 it_is_structure_list

    it_is_structure_list $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::List>.

=head2 it_is_structure_subscript

    it_is_structure_subscript $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::Subscript>.

=head2 it_is_structure_when

    it_is_structure_when $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Structure::When>.

=head2 it_is_token

    it_is_token $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token>.

=head2 it_is_token_array_index

    it_is_token_array_index $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::ArrayIndex>.

=head2 it_is_token_attribute

    it_is_token_attribute $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Attribute>.

=head2 it_is_token_cast

    it_is_token_cast $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Cast>.

=head2 it_is_token_comment

    it_is_token_comment $element?, @it_is_conditions?

Classify L</effective element> as L<PPI::Token::Comment>.

=head2 it_is_token_data

    it_is_token_data $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::Data>.

=head2 it_is_token_end

    it_is_token_end $element?, @conditions?

Shortcut for calling L</it_is> with L<PPI::Token::End>.

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
