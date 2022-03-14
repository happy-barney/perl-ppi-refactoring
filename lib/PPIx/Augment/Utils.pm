
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use Exporter    qw[ import ];
	use Attribute::Handlers;

	use PPIx::Utils qw[];
	use Ref::Util   qw[];
	use Safe::Isa;

	use PPIx::Augment::Elements;

	our @EXPORT;
	our @EXPORT_OK;

	sub EXPORT :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT, *{$symbol}{NAME};
		push @EXPORT_OK, *{$symbol}{NAME};
	}

	sub EXPORT_OK :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT_OK, *{$symbol}{NAME};
	}

	sub _ppi_false                  :EXPORT {
		0;
	}

	sub _ppi_false_dont_descent     :EXPORT {
		();
	}

	sub _ppi_true                   :EXPORT {
		1;
	}

	sub _build_where {
		my ($where, @where) = grep $_->isa ('PPIx::Augment::Utils::Where'), @_;

		if (@where) {
			unshift @where, $where;
			$where = sub {
				my $context = $_;
				my $result = 1;
				for my $element (@where) {
					$result &&= $element->(@_);
				}
				$result;
			};
		}

		return $where // sub { };
	}

	sub _build_invoke {
		my ($invoke) = grep $_->isa ('PPIx::Augment::Utils::Invoke'), @_;

		return $invoke // sub { };
	}

	sub _create_token {
		my ($class, $content) = @_;

		return unless length ($content // '');

		return $class->new ($content);
	}

	sub _it_args {
		return @_
			if ref $_[0] && $_[0]->$_isa (PPI::Element::);

		return ($_, @_);
	}

	sub _its_where {
		my ($element, $code) = @_;

		return _ppi_false unless $element;

		local $_ = $element;

		$code->();
	}

	sub clone_indent                :EXPORT {
		my ($element) = _it_args @_;

		my $previous_sibling = $element->previous_sibling;

		return
			unless $previous_sibling;

		return
			unless it_is_insignificant ($previous_sibling);

		my $content = $previous_sibling->content =~ s/[\r\n]//gr;

		return
			unless $content;

		return create_token_whitespace ($content);
	}

	sub create_statement            :EXPORT {
		element_create (PPI::Statement:: => @_);
	}

	sub create_statement_expression :EXPORT {
		element_create (PPI::Statement::Expression:: => @_);
	}

	sub create_statement_variable   :EXPORT {
		element_create (PPI::Statement::Variable:: => @_);
	}

	sub create_statement_include    :EXPORT {
		element_create (PPI::Statement::Include:: => @_);
	}

	sub create_structure            :EXPORT {
		my ($type, $token, @content) = @_;

		my $start  = create_token_structure ($token);
		my $finish = create_token_structure ($token =~ tr/([{/)]}/r);

		my $element = $type->new ($start);
		element_add ($element, @content);
		$element->{finish} = $finish;

		$element;
	}

	sub create_structure_list       :EXPORT {
		create_structure ("PPI::Structure::List" => shift, create_statement_expression (@_));
	}

	sub create_token_cast ($)       :EXPORT {
		_create_token (PPI::Token::Cast::, @_);
	}

	sub create_token_new_line       :EXPORT {
		create_token_whitespace ("\n");
	}

	sub create_token_operator ($)   :EXPORT {
		_create_token (PPI::Token::Operator::, @_);
	}

	sub create_token_semicolon      :EXPORT {
		create_token_structure (';');
	}

	sub create_token_structure ($)  :EXPORT {
		_create_token (PPI::Token::Structure::, @_);
	}

	sub create_token_word ($)       :EXPORT {
		_create_token (PPI::Token::Word::, @_);
	}

	sub create_token_word_list      :EXPORT {
		my ($content) = @_;
		$content = "qw" . $content unless $content =~ m/^qw/;

		my $token = PPI::Token::QuoteLike::Words->new ('qw');
		$token->set_content ($content);
		$token->{sections} = [ { position => 2, size => length ($content) - 2 } ];
		$token;
	}

	sub create_token_whitespace ($) :EXPORT {
		_create_token (PPI::Token::Whitespace::, @_);
	}

	sub current                     :EXPORT {
		$_;
	}

	sub current_content             :EXPORT {
		$_->content;
	}

	sub current_insert_after        :EXPORT {
		element_insert_after ($_, @_);
	}

	sub current_insert_before       :EXPORT {
		element_insert_before ($_, @_);
	}

	sub current_remove              :EXPORT {
		$_->remove;
	}

	sub current_replace             :EXPORT {
		element_replace ($_, @_);
	}

	sub current_replace_with        :EXPORT {
		element_replace_with ($_, @_);
	}

	sub element_add                 :EXPORT {
		my ($element, @content) = @_;

		for (@content) {
			my $add = $_;
			if ($_->parent) {
				$add = $_->clone;
				$_->remove;
			}

			$element->add_element ($add);
		}

		$element;
	}

	sub element_create              :EXPORT {
		my ($class, @content) = @_;

		my $element = $class->new;

		element_add ($element, @content);
	}

	sub element_insert_after        :EXPORT {
		my $element = shift;

		# skip PPI's restrictions
		$element->__insert_after ($_) for @_;
	}

	sub element_insert_before       :EXPORT {
		my $element = shift;

		# skip PPI's restrictions
		$element->__insert_before ($_) for @_;
	}

	sub element_remove              :EXPORT {
		$_->remove for @_;
	}

	sub element_replace             :EXPORT {
		my ($element, @with_content) = @_;

		my @to_remove = grep $_->parent, $element, @with_content;

		$element->__insert_before ($_)
			for
				map { $_->parent ? $_->clone : $_ }
				grep { ref }
				@with_content
				;

		$_->remove for @to_remove;

		();
	}

	sub element_replace_with        :EXPORT {
		my ($element, $class, @elements) = @_;

		my @to_remove = grep $_->parent, @elements;

		my $new_element;
		if ($class->isa (PPI::Token::)) {
			$new_element = $class->new (join '', @elements);
		} else {
			$new_element = $class->new;
			$new_element->add_element ($_->parent ? $_->clone : $_)
				for @elements;
		}

		$element->__insert_before ($new_element);

		$_->remove for @to_remove;

		return $new_element;
	}

	sub following_insignificant     :EXPORT {
		my ($element) = _it_args @_;

		my @following_insignificant;

		while (it_is_insignificant ($element->next_sibling)) {
			push @following_insignificant, $element->next_sibling;
			$element = $following_insignificant[-1];
		}

		return @following_insignificant;
	}

	sub invoke (&)                  :EXPORT {
		bless $_[0], 'PPIx::Augment::Utils::Invoke';
	}

	sub it_is                       :EXPORT {
		my ($element, $class, $content) = _it_args @_;

		return _ppi_false unless $element->$_isa ($class);
		return _ppi_true unless defined $content;

		my $method = 'content';
		if (Ref::Util::is_plain_hashref ($content)) {
			($method, $content) = %$content;
		}

		return (scalar ($element->$method =~ $content) // _ppi_false)
			if Ref::Util::is_regexpref ($content);

		return (($element->$method eq $content) // _ppi_false);
	}

	sub it_is_augmented             :EXPORT {
		my ($element) = _it_args @_;

		it_is ($element, PPIx::Augment::Element::);
	}

	sub it_is_augmented_dereference :EXPORT {
		my ($element) = _it_args @_;

		it_is ($element, PPIx::Augment::Expression::Term::Dereference::);
	}

	sub it_is_augmented_variable    :EXPORT {
		my ($element) = _it_args @_;

		it_is ($element, PPIx::Augment::Expression::Term::Variable::);
	}

	sub it_is_document              :EXPORT {
		my ($element) = _it_args @_;

		it_is ($element, PPI::Document::);
	}

	sub it_is_insignificant         :EXPORT {
		my ($element) = _it_args @_;

		return _ppi_false unless $element;
		return _ppi_false if $element->significant;

		return _ppi_true;
	}

	sub it_is_literal               :EXPORT {
		my ($element) = _it_args @_;

		return _ppi_false
			|| it_is ($element, PPI::Token::Number::)
			|| it_is ($element, PPI::Token::Quote::)
			|| it_is ($element, PPI::Token::QuoteLike::)
			|| it_is ($element, PPI::Token::Regexp::)
			;
	}

	sub it_is_method_call           :EXPORT {
		my ($element) = _it_args @_;

		return _ppi_false unless PPIx::Utils::is_method_call ($element);

		return _ppi_true if it_is_token_symbol ($element);
		return _ppi_true if it_is_token_word ($element);
		return _ppi_true if it_is_token_cast ($element, '$');

		return _ppi_false;
	}

	sub it_is_node                  :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Node::;
	}

	sub it_is_operator              :EXPORT {
		my ($element, $content) = _it_args @_;

		it_is $element, PPI::Token::Operator::, $content;
	}

	sub it_is_operator_arrow        :EXPORT {
		my ($element) = _it_args @_;

		it_is_operator $element, '->';
	}

	sub it_is_operator_fat_arrow    :EXPORT {
		my ($element) = _it_args @_;

		it_is_operator $element, '=>';
	}

	sub it_is_operator_bitwise_xor  :EXPORT {
		my ($element) = _it_args @_;

		it_is_operator $element, '^';
	}

	sub it_is_operator_modulus      :EXPORT {
		my ($element) = _it_args @_;

		it_is_operator $element, '%';
	}

	sub it_is_statement             :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Statement::, $content);
	}

	sub it_is_structure_block       :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Structure::Block::, $content);
	}

	sub it_is_structure             :EXPORT {
		my ($element, $class, $content) = _it_args @_;

		return _ppi_false unless it_is ($element, $class);
		return _ppi_true unless $content;

		return _ppi_true if $element->start  eq $content;
		return _ppi_true if $element->finish eq $content;
		return _ppi_true if $element->braces eq $content;

		return _ppi_false;
	}

	sub it_is_structure_constructor :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is_structure ($element, PPI::Structure::Constructor::, $content);
	}

	sub it_is_structure_subscript   :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is_structure ($element, PPI::Structure::Subscript::, $content);
	}

	sub it_is_token_cast            :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Token::Cast::, $content);
	}

	sub it_is_token_label           :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Label::;
	}

	sub it_is_token_magic           :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Token::Magic::, $content);
	}

	sub it_is_token_number          :EXPORT {
		my ($element, $content) = _it_args @_;

		it_is $element, PPI::Token::Number::, $content;
	}

	sub it_is_token_number_binary   :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Number::Binary::;
	}

	sub it_is_token_number_float    :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Number::Float::;
	}

	sub it_is_token_number_hex      :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Number::Hex::;
	}

	sub it_is_token_number_octal    :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Number::Octal::;
	}

	sub it_is_token_number_version  :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Number::Version::;
	}

	sub it_is_token_quote           :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Quote::;
	}

	sub it_is_token_quote_double    :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Quote::Double::;
	}

	sub it_is_token_quote_interpolate :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Quote::Interpolate::;
	}

	sub it_is_token_quote_literal   :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Quote::Literal::;
	}

	sub it_is_token_quote_single    :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::Quote::Single::;
	}

	sub it_is_token_quotelike       :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::QuoteLike::;
	}

	sub it_is_token_quotelike_backtick :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::QuoteLike::Backtick::;
	}

	sub it_is_token_quotelike_command :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::QuoteLike::Command::;
	}

	sub it_is_token_quotelike_regex :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::QuoteLike::Regexp::;
	}

	sub it_is_token_quotelike_words :EXPORT {
		my ($element) = _it_args @_;

		it_is $element, PPI::Token::QuoteLike::Words::;
	}

	sub it_is_token_symbol          :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Token::Symbol::, $content);
	}

	sub it_is_token_word            :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Token::Word::, $content);
	}

	sub it_is_token_whitespace      :EXPORT {
		my ($element, $content) = _it_args @_;

		return it_is ($element, PPI::Token::Whitespace::, $content);
	}

	sub it_is_statement_include     :EXPORT {
		my ($element, $content) = _it_args @_;

		return _ppi_false unless it_is ($element, PPI::Statement::Include::);
		return _ppi_false if $content and $element->type ne $content;

		return _ppi_true;
	}

	sub it_is_statement_package     :EXPORT {
		my ($element, $content) = _it_args @_;

		return _ppi_false unless it_is ($element, PPI::Statement::Package::);
		return _ppi_false if $content and $element->namespace ne $content;

		return _ppi_true;
	}

	sub it_is_statement_use         :EXPORT {
		my ($element, $module) = _it_args @_;

		return _ppi_false unless it_is_statement_include ($element, 'use');
		return _ppi_false if $module and $element->module ne $module;

		return _ppi_true;
	}

	sub it_isnt_augmented_yet       :EXPORT {
		my ($element) = _it_args @_;

		return _ppi_false_dont_descent if it_is_augmented ($element);
		return _ppi_false_dont_descent if it_is_augmented ($element->parent);

		return _ppi_true;
	}

	sub its_last_element (&)        :EXPORT {
		_its_where $_->last_element, @_;
	}

	sub its_next_sibling (&)        :EXPORT {
		_its_where $_->next_sibling, @_;
	}

	sub its_previous_sibling (&)    :EXPORT {
		_its_where $_->previous_sibling, @_;
	}

	sub its_snext_sibling (&)       :EXPORT {
		_its_where $_->snext_sibling, @_;
	}

	sub its_sprevious_sibling (&)   :EXPORT {
		_its_where $_->sprevious_sibling, @_;
	}

	sub its_parent (&)              :EXPORT {
		_its_where $_->parent, @_;
	}

	sub find_filename               :EXPORT {
		my ($element) = _it_args @_;

		while (1) {
			return '' unless $element;
			return $element->filename if $element->$_isa (PPI::Document::);
			$element = $element->parent;
		}
	}

	sub move_next_insignificant     :EXPORT {
		my ($from_element, $to_element) = @_;

		while (my $sibling = $from_element->next_sibling) {
			last if $sibling->significant;

			move_next_sibling ($from_element, $to_element);
		}
	}

	sub move_next_sibling           :EXPORT {
		my ($from_element, $to_element) = @_;

		if (my $sibling = $from_element->next_sibling) {
			$to_element->add_element ($sibling->clone);
			$sibling->remove;
		}
	}

	sub move_prev_insignificant     :EXPORT {
		my ($from_element, $to_element) = @_;

		while (my $sibling = $from_element->next_sibling) {
			last if $sibling->significant;

			move_prev_sibling ($from_element, $to_element);
		}
	}

	sub move_prev_sibling           :EXPORT {
		my ($from_element, $to_element) = @_;

		if (my $sibling = $from_element->next_sibling) {
			$to_element->add_element ($sibling->clone);
			$sibling->remove;
		}
	}

	sub next_sibling                :EXPORT {
		my ($element) = _it_args @_;

		$_->next_sibling;
	}

	sub operator_is_expected        :EXPORT {
		my ($element) = _it_args @_;

		my $previous = $element->sprevious_sibling;

		return _ppi_false unless $previous;

		if ($element->content eq '%') {
			return _ppi_false if it_is_operator ($previous);
			return _ppi_false if it_is_token_word ($previous, qr/^(my|our|local|state)$/);
			return _ppi_true;
		}

		return _ppi_true;
	}

	sub operator_isnt_expected      :EXPORT {
		! &operator_is_expected;
	}

	sub parent                      :EXPORT {
		my ($element) = _it_args @_;

		return unless $element;
		return $element->parent;
	}

	sub ppix_find                   :EXPORT {
		my ($element, $what, @args) = @_;

		return unless $element;
		my $where = Ref::Util::is_coderef ($what)
			? sub { local $_ = $_[1]; $what->($_[1], @args) }
			: $what
			;
		@{ $element->find ($where) || [] };
	}

	sub ppix_process                :EXPORT {
		my ($element, @params) = @_;

		my $where = _build_where (@params);
		my $invoke = _build_invoke (@params);

		for (ppix_find $element, $where) {
			$invoke->();
		}
	}

	sub _ppix_transform {
		my ($element, $start, $step, @params) = @_;

		my $where = _build_where (@params);
		my $invoke = _build_invoke (@params);

		my $rv = 0;
		my @current = ([ $element, $start ]);

		while (@current) {
			my ($current, $index) = @{ shift @current };
			next unless $current;
			local $_ = $current;
			# when $current is replaced it losts its parent reference
			my $parent = $current->parent;

			if ($parent) {
				my $next_index = $index + $step;
				unshift @current, [ $parent->child ($next_index), $next_index ]
			}

			if ($where->()) {
				$rv++;
				$invoke->();
				$current = $parent->child ($index)
					if $parent;
			}

			unshift @current, [ $current->child ($start), $start ]
				if $current->$_isa (PPI::Node::);
		}

		return $rv;
	}

	sub ppix_transform              :EXPORT {
		my ($element, @params) = @_;

		_ppix_transform ($element, 0, 1, @params);
	}

	sub ppix_transform_reverse      :EXPORT {
		my ($element, @params) = @_;

		_ppix_transform ($element, -1, -1, @params);
	}

	sub significant_children        :EXPORT {
		my ($element) = _it_args @_;

		return unless it_is_node $element;

		grep $_->significant, $element->children;
	}

	sub snext_sibling               :EXPORT {
		my ($element) = _it_args @_;

		$_->snext_sibling;
	}

	sub where (&)                   :EXPORT {
		bless $_[0], 'PPIx::Augment::Utils::Where';
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils - PPI processing utils

=head1 DESCRIPTION

Based on L<PPIx::Utils> idea, provides additional PPI utils.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
