
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

	sub augment_build :EXPORT {
		my ($class, $first, @children) = @_;

		my $element = element_create ($class => $first->clone);

		for my $child (grep $_, @children) {
			element_move_next_insignificant ($element, first);
			element_move_next_sibling       ($element, first);
		}

		return element_replace ($first, $element);

	}

	sub augment_snext_sibling :EXPORT {
		my ($class, $augment_from) = @_;

		augment_build ($class, $augment_from->snext_sibling);
	}

	sub augment_sprevious_sibling :EXPORT {
		my ($class, $augment_from) = @_;

		augment_build ($class, $augment_from->sprevious_sibling);
	}

	sub element_create :EXPORT {
		my ($type, @content) = @_;

		return unless $type->isa ('PPI::Node');

		my $node = $type->new;
		$node->add_element ($_) for @content;

		return $node;
	}

	sub element_move_next_insignificant :EXPORT {
		my ($into, $from_element) = @_;

		while (my $sibling = $from_element->next_sibling) {
			last if $sibling->significant;
			$into->add_element ($sibling->clone);
			$sibling->remove;
		}
	}

	sub element_move_next_sibling :EXPORT {
		my ($into, $from_element) = @_;

		my $sibling = $from_element->next_sibling;
		$into->add_element ($sibling->clone);
		$sibling->remove;
	}

	sub element_replace :EXPORT {
		my ($element, @with_content) = @_;
		@with_content = grep $_, @with_content;

		return $element unless @with_content;

		$element->__insert_before ($_) for @with_content;
		$element->remove;

		return $with_content[0];
	}

	sub it_is_expression_method_reference :EXPORT {
		my ($element) = _it_args @_;

		return _is_a ($element, 'PPIx::Augment::Expression::Method_Reference');
	}

	sub it_is_operator_arrow :EXPORT {
		my ($element) = _it_args @_;

		_is_operator ($element, '->');
	}

	sub it_is_structure_list :EXPORT {
		my ($element) = _it_args @_;

		$element->$_isa ('PPI::Structure::List') || 0;
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

__END__

sub where (&);

sub _d :EXPORT {
	return unless $_[0];
	PPI::Dumper->new ($_[0])->print;
}

sub append_statement_with_same_indent :EXPORT {
	my ($element, $statement) = @_;

	$element->insert_after (create_token_whitespace ("\n\t$statement"));
}

sub content :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return $element->content;
}

sub create_argument_list :EXPORT {
	create_structure_list (
		'(',
		@_ ? create_token_whitespace (' ') : (),
		@_,
		@_ ? create_token_whitespace (' ') : (),
	);
}

sub create_element :EXPORT {
	my ($text) = @_;

	my $element = PPI::Node->new;
	$element->content ($text);

	$element;
}

sub create_node {
	my ($type, @content) = @_;

	return unless $type->isa ('PPI::Node');

	my $node = $type->new;
	$node->add_element ($_) for @content;

	$node;
}

sub create_operator_arrow :EXPORT {
	create_token_operator ('->');
}

sub create_operator_assign :EXPORT {
	create_token_operator ('=');
}

sub create_operator_fat_comma :EXPORT {
	create_token_operator ('=>');
}

sub create_statement :EXPORT {
	create_node ("PPI::Statement" => @_);
}

sub create_statement_expression :EXPORT {
	create_node ("PPI::Statement::Expression" => @_);
}

sub create_statement_variable :EXPORT {
	create_node ("PPI::Statement::Variable" => @_);
}

sub create_statement_include :EXPORT {
	create_node ("PPI::Statement::Include" => @_);
}

sub create_structure :EXPORT {
	my ($type, $token, @content) = @_;

	my $start_element = PPI::Token::Structure->new ($token);
	my $end_element = PPI::Token::Structure->new ($token =~ tr/([{/)]}/r);

	my $node = $type->new ($start_element);
	$node->add_element ($_) for @content;
	$node->{finish} = $end_element;

	$node;
}

sub create_structure_list :EXPORT {
	create_structure ("PPI::Structure::List" => shift, create_statement_expression (@_));
}

sub create_structure_subscript :EXPORT {
	create_structure ("PPI::Structure::Subscript" => shift, create_statement_expression (@_));
}

sub create_token_label :EXPORT {
	PPI::Token::Label->new ($_[0]);
}

sub create_token_magic :EXPORT {
	PPI::Token::Magic->new ($_[0]);
}

sub create_token_new_line :EXPORT {
	create_token_whitespace ("\n");
}

sub create_token_operator :EXPORT {
	PPI::Token::Operator->new ($_[0]);
}

sub create_token_semicolon :EXPORT {
	create_token_structure (';');
}

sub create_token_structure :EXPORT {
	PPI::Token::Structure->new ($_[0]);
}

sub create_token_symbol :EXPORT {
	PPI::Token::Symbol->new ($_[0]);
}

sub create_token_word :EXPORT {
	PPI::Token::Word->new ($_[0]);
}

sub create_token_word_list :EXPORT {
	my $token = PPI::Token::QuoteLike::Words->new ('qw');
	$token->set_content ($_[0]);
	$token;
}

sub create_token_whitespace :EXPORT {
	PPI::Token::Whitespace->new ($_[0]);
}

sub create_token_comment :EXPORT {
	PPI::Token::Comment->new ('# ' . $_[0]);
}

sub create_token_version :EXPORT {
	PPI::Token::Number::Version->new ($_[0]);
}

sub create_single_quoted :EXPORT {
	my $content = $_[0];
	$content =~ s/(?=[\\'])/\\/g;
	PPI::Token::Quote::Single->new ("'$_[0]'");
}

sub find_call_parameters :EXPORT {
	my ($element) = @_;

	return unless is_list ($element->snext_sibling);
	parse_arg_list ($element);
}

sub find_caller_method :EXPORT {
	my ($element) = @_;

	my $candidate = $element->parent->parent->sprevious_sibling;

	is_method_call ($candidate) ? $candidate : '';
}

sub find_caller_invocant :EXPORT {
	my ($element, $name) = @_;

	my $method = find_caller_method ($element);

	$method
		? find_invocant ($method, $name)
		: ''
		;
}

sub find_declared_functions :EXPORT {
	my ($element) = @_;

	ppix_find ($element, where {
		is_ppi_statement_sub ($_)
		&& $_->block
	});
}

sub find_declared_functions_map :EXPORT {
	my ($element) = @_;

	map +( $_->name => $_),
		ppix_find ($element, where {
			is_ppi_statement_sub ($_)
			&& $_->block
		});
}

sub find_declared_function_names :EXPORT {
	my ($element) = @_;

	map $_->name,
		ppix_find ($element, where {
			is_ppi_statement_sub ($_)
			&& $_->block
		});
}

sub find_declared_functions_not_called_as_methods :EXPORT {
	my ($document) = @_;
	my %module_functions = map +($_->name => 1), find_declared_function_names ($document);

	grep { is_function_call( $_ ) }
	grep { $module_functions{$_->literal} }
	@{ $document->find (sub { $_[1]->isa ('PPI::Token::Word') }) // [] }
}

sub find_expression_indent :EXPORT {
	my ($element) = @_;

	my $line_number = $element->line_number;

	while ($element->line_number == $line_number) {
		die if $element eq $element->previous_token;
		#say " from $element to ${\ $element->previous_token }";
		$element = $element->previous_token;
	}

	my (@indent);
	while (is_whitespace ($element)) {
		push @indent, $element;
		$element = $element->next_token;
	}

	join '', map $_->content, @indent;
}

sub is_function_block :EXPORT {
}

sub is_function_argument :EXPORT {
#	is_ppi_token_symbol ($_)
#		&& do {
#			my $scope = find_variable_scope ($_);
#
#			
}

sub find_owning_sub_block {
	my ($element) = @_;

	return unless $element;
	return $element
		if is_ppi_structure_block ($element)
		&& (
			'sub' eq sprevious_sibling ($element)
			|| is_ppi_statement_sub ($element->parent)
		)
			#	|| 'sub' eq sprevious_sibling (sprevious_sibling ($element))
			#);
			;

	return __SUB__->($element->parent);
}

sub find_function_argument_names :EXPORT {
	my ($element) = @_;

	return unless is_ppi_statement_sub ($element);

	my @list = ppix_find (
		$element->block,
		where {
			is_ppi_token_symbol ($_)
				&& is_list ($_->parent->parent)
				&& is_operator_assign ($_->parent->parent->snext_sibling)
				&& is_ppi_token_magic ($_->parent->parent->snext_sibling->snext_sibling)
				&& $element->block == find_owning_sub_block ($_)
			}
	);

	@list;
}

sub find_function_call :EXPORT {
	my ($element) = @_;

	return
		grep { is_function_call ($element) || is_method_call ($element) }
		ppi_find ($element => 'PPI::Token::Word' )
		;
}

sub find_function_call_arguments :EXPORT {
	my ($element) = @_;

	return
		unless $element;

	return split_list ($element->snext_sibling)
		if is_ppi_structure_list ($element->snext_sibling);

	();
}

sub find_invocant :EXPORT {
	my ($element) = @_;

	return unless is_method_call ($element);

	# returns structure preceding operator arrow
	$element->sprevious_sibling->sprevious_sibling;
}

sub find_invoked_method :EXPORT {
	my ($element) = @_;

	$element = snext_sibling ($element);
	$element = snext_sibling ($element) if is_list ($element);

	return unless is_operator_arrow ($element);
	return snext_sibling ($element);
}

sub find_operator_arrow :EXPORT {
	ppi_find ($_[0] => sub { is_operator_arrow ($_[1]) });
}

sub find_variable_by_name :EXPORT {
	my ($element, $name) = @_;

	grep { $_ eq $name }
		ppi_find ($element, 'PPI::Token::Symbol')
		;
}

sub find_variable_initialization_expression :EXPORT {
	my ($element) = @_;

	$element = $element->snext_sibling
		until $element && is_operator_assign ($element);

	$element = $element->$_call_if_object ('snext_sibling');

	return unless $element;

	my @expression;
	while ($element && ! is_semicolon ($element)) {
		push @expression, $element;
		$element = $element->next_sibling;
	}

	pop @expression while @expression && is_whitespace ($expression[-1]);

	@expression;
}

sub find_variable_scope :EXPORT {
	my ($variable) = @_;

	$variable = $variable->parent
		until $variable && is_ppi_structure_block ($variable);

	$variable;
}

sub find_variable_usage :EXPORT {
	my ($element, $block) = @_;
	$block = find_variable_scope ($element)
		unless defined $block;

	my @list =
		grep { $_->symbol eq $element->symbol }
		ppi_find ($block, 'PPI::Token::Symbol')
		;

	shift @list if is_variable_declaration ($list[0]);

	push @list, grep m/\Q$element\E\b/,
		ppi_find ($block, 'PPI::Token::Quote::Double'),
		ppi_find ($block, 'PPI::Token::Regexp::Match'),
		ppi_find ($block, 'PPI::Token::QuoteLike::Regexp'),
		;

	@list;
}

sub find_has_declaration :EXPORT {
	my ($scope, $where) = @_;

	my @list = ppix_find ($scope, where {
		return 0 unless ref eq 'PPI::Statement';
		my $first = $_->child (0);
		return 0 unless $first->isa ('PPI::Token::Word');
		return 0 unless $first->content eq 'has';
		1;
	});

	@list;
}

sub has_no_arguments :EXPORT {
	my ($element) = @_;

	return 1 if is_operator_comma ($element->snext_sibling);

	! scalar parse_arg_list ($element);
}

sub has_magic_argument :EXPORT {
	my ($element) = @_;

	is_ppi_token_magic (first_arg ($element));
}

sub has_snext_sibling :EXPORT {
	my ($element) = @_;

	return 0 unless $element;
	return 0 unless $element->snext_sibling;
	return 1;
}

sub insert_after_element :EXPORT {
	my ($element, @content) = @_;

	$element->__insert_after ($_) for reverse @content;
}

sub insert_before_current :EXPORT {
	my $context = $_;

	$context->__insert_before ($_) for @_;
}

sub insert_before_element :EXPORT {
	my ($element, @content) = @_;

	$element->insert_before ($_) for @content;
}

sub is_argument_declaration :EXPORT {
	my ($element) = @_;

	my @magic = ppi_find ($element, 'PPI::Token::Magic');

	@magic == 1 && is_semicolon ($magic[0]->snext_sibling);
}

sub is_followed_by :EXPORT {
	my ($element, @sequence) = @_;

	return unless $element;

	local $_ = $element;

	while (@sequence) {
		$_ = $_->snext_sibling;
		return 0 unless $_;
		return 0 unless $sequence[0]->($_);

		shift @sequence;
	}

	return 1;
}

sub is_invocant :EXPORT {
	my ($element, $method) = @_;

	return 0 if is_ppi_structure_list ($element);
	return 0 unless $element;

	$element = $element->snext_sibling;

	$element = $element->snext_sibling
		if is_ppi_structure_list ($element);

	return 0 unless $element;
	return 0 unless is_operator_arrow ($element);

	return $element->snext_sibling eq $method
		if defined $method;

	return 1;
}

sub is_label :EXPORT {
	my ($element, $name) = @_ ? @_ : ($_);

	$element->$_isa ('PPI::Token::Label');
}

sub is_list :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Structure::List' );
}

sub is_method_call :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return 0 unless PPIx::Utils::is_method_call ($element);

	return 1 if is_ppi_token_symbol ($element);
	return 1 if is_ppi_token_word ($element);
	return 1 if is_ppi_token_cast ($element) && $element->content eq '$';

	return 0;
}

sub is_method_call_name :EXPORT {
	my ($element, $name) = @_;

	return 0 unless is_method_call ($element);
	return 0 unless is_ppi_token_word ($element);
	return $element eq $name if defined $name;
	return 1;
}

sub is_method_call_on :EXPORT {
	my ($element, $name) = @_;

	return 0 unless is_method_call ($element);
	my $invocant = find_invocant ($element);

	return $invocant eq $name;
}

sub is_method_call_on_self :EXPORT {
	my ($element) = @_;

	is_method_call_on ('$self');
}

sub is_method_parameter :EXPORT {
	my ($element) = @_;

	is_method_call ($_)
		&& is_method_call (find_caller_method ($_))
		;
}

sub is_not_invocant :EXPORT {
	my ($element) = @_;

	! is_invocant ($element);
}

sub is_operator_assign :EXPORT {
	my ($element) = @_;

	is_operator ($element, '=');
}

sub is_operator_boolean_or :EXPORT {
	my ($element) = @_;

	is_operator ($element, '||');
}

sub is_operator_any_comma :EXPORT {
	my ($element) = @_;

	is_operator_comma ($element) || is_operator_fat_comma ($element);
}

sub is_operator_comma :EXPORT {
	my ($element) = @_;

	is_operator ($element, ',');
}

sub is_operator_fat_comma :EXPORT {
	my ($element) = @_;

	is_operator ($element, '=>');
}

sub is_operator_question_mark :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	is_operator ($element, '?');
}

sub is_parameter :EXPORT {
	my ($element) = @_;

	return 1
		if is_ppi_expression ($element->parent)
		&& is_list ($element->parent->parent)
		;

	return 0;
}

sub is_ppi_element {
	$_[0]->$_isa ('PPI::Element');
}

sub is_ppi_structure_block :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Structure::Block') // 0;
}

sub is_ppi_structure_list :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Structure::List') // 0;
}

sub is_ppi_structure_subscript :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Structure::Subscript') // 0;
}

sub is_ppi_statement_expression :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Statement::Expression') // 0;
}

sub is_ppi_statement_include :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Statement::Include') // 0;
}

sub is_ppi_statement_sub :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Statement::Sub') // 0;
}

sub is_ppi_statement_variable :EXPORT {
	my ($element) = @_;

	$element->$_isa ('PPI::Statement::Variable') // 0;
}

sub is_ppi_token_cast :EXPORT {
	my ($element, $name) = @_;

	return 0 unless $element->$_isa ('PPI::Token::Cast');
	return $element eq $name if defined $name;
	return 1;
}

sub is_ppi_token_magic :EXPORT {
	my ($element, $name) = @_;

	return unless $element->$_isa ('PPI::Token::Magic');
	return $element->content eq $name if defined $name;
	return 1;
}

sub is_ppi_token_symbol :EXPORT {
	my ($element, $name) = @_;

	return 0 unless $element->$_isa ('PPI::Token::Symbol');
	return $element eq $name if defined $name;
	return 1;
}

sub is_ppi_token_word :EXPORT {
	my ($element, $name) = @_;

	return 0 unless $element->$_isa ('PPI::Token::Word');
	return $element eq $name if defined $name;
	return 1;
}

sub is_project_context_method_call :EXPORT {
	my ($element) = @_;

	$element->$_isa( 'PPI::Token::Symbol' )
		&& $element->symbol eq '$project_context'
		&& is_method_call ($element)
		;
}

sub is_semicolon :EXPORT {
	my ($element) = @_;

	$element->isa ('PPI::Token::Structure') && $element->content eq ';';
}

sub is_subroutine_definition :EXPORT {
	my ($element) = @_;

	is_subroutine_declaration ($element)
		&& scalar ppi_find ($element => 'PPI::Structure::Block');
}

sub is_symbol :EXPORT {
	my ($element, $name) = @_;

	return 0 unless $element;
	return unless $element->isa ('PPI::Token::Symbol');
	return $element->content eq $name if defined $name;
	return 1;
}

sub is_token_my :EXPORT {
	my ($element) = @_;

	is_ppi_token_word ($element, 'my');
}

sub is_token_package :EXPORT {
	my ($element) = @_;

	is_ppi_token_word ($element, '__PACKAGE__');
}

sub is_token_shift :EXPORT {
	my ($element) = @_;

	is_ppi_token_word ($element, 'shift');
}

sub is_unary_operator :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return 0 unless is_operator ($element);
	return 1 unless $element->sprevious_sibling;
	return 1 if is_operator ($element->sprevious_sibling);

	return 0;
}

sub is_use_statement :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return unless $element->isa ('PPI::Statement::Include');
	return $element->type eq 'use';
}

sub is_variable_declaration :EXPORT {
	my ($element) = @_;

	return $element
		if is_ppi_statement_variable ($element);

	return $element->parent
		if is_ppi_statement_variable ($element->parent);

	return;
}

sub is_whitespace :EXPORT {
	my ($element) = @_;

	ref $element && $element->isa ('PPI::Token::Whitespace');
}

sub its_snext_sibling :EXPORT {
	return unless $_;
	return $_->snext_sibling;
}

sub its_snext_sibling_is (&) :EXPORT {
	my ($code) = @_;

	local $_ = its_snext_sibling;

	return unless $_;

	$code->();
}

sub its_sprevious_sibling :EXPORT {
	return unless $_;
	return $_->sprevious_sibling;
}

sub its_sprevious_sibling_is (&) :EXPORT {
	my ($code) = @_;

	local $_ = its_sprevious_sibling;

	return unless $_;

	$code->();
}

sub it_is {
	my ($package) = @_;

	$_->$_isa ($package) || 0;
}

sub it_is_structure_block :EXPORT {
	it_is (PPI::Structure::Block::);
}

sub it_is_token_cast :EXPORT {
	my (@types) = @_;
	my $element = $_;

	return 0 unless it_is (PPI::Token::Cast::);
	return 1 unless @types;

	return 1 if grep { $element eq $_ } @types;
	return 0;
}

sub match_content :EXPORT {
	my ($element, $match) = @_;

	# undef means 'ignore'
	return 1 unless defined $match;

	return $element eq $match unless ref $match;
	return $element =~ $match if Ref::Util::is_regexpref ($match);

	return 0;
}

sub method_invocant :EXPORT {
	my ($element) = @_;

	return '' unless is_method_call ($element);
	$element->sprevious_sibling->sprevious_sibling;
}

sub next_sibling :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return $element unless $element;
	return $element->next_sibling;
}

sub next_token :EXPORT {
	my ($element) = @_;

	return $element unless $element;
	return $element->next_token;
}

sub operator_arrow :EXPORT {
	PPI::Token::Operator->new ('->');
}

sub parent :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return $element->parent // $element;
}

sub ppi_find :EXPORT {
	my ($element, @what) = @_;

	return unless $element;
	@{ $element->find (@what) || [] };
}

sub ppix_find :EXPORT {
	my ($element, $what, @args) = @_;

	return unless $element;
	my $where = Ref::Util::is_coderef ($what)
		? sub { local $_ = $_[1]; $what->($_[1], @args) }
		: $what
		;
	@{ $element->find ($where) || [] };
}

sub ppix_invoke :EXPORT {
	my (%params) = @_;

	for (ppix_find ($params{element}, $params{where})) {
		$params{invoke}->($_);
	}
}

sub ppix_process :EXPORT {
	my ($element, @params) = @_;

	my ($where, @where) = grep $_->isa ('HPB::PPIx::Utils::Where'), @params;
	my ($invoke) = grep $_->isa ('HPB::PPIx::Utils::Invoke'), @params;

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

	my @found = ppix_find ($element, $where);
	for (@found) {
		$invoke->($_);
	}

	scalar @found;
}

sub ppi_location :EXPORT {
	my ($element, $format) = @_;
	$format //= "line {line_number} column {column_number}";

	my $line_number = $element->line_number;
	my $column_number = $element->column_number;

	while (1) {
		$element = $element->previous_token;
		last unless $element;
		last unless $element->line_number == $line_number;
		next unless is_whitespace ($element);

		$column_number += 3 for $element =~ m/\t/g;
	}

	$format =~ s/\{line_number\}/$line_number/g;
	$format =~ s/\{column_number\}/$column_number/g;

	$format;
}

sub ppi_location_emacs :EXPORT {
	my ($element) = @_;

	ppi_location ($element, "{line_number}:{column_number}");
}

sub previous_sibling :EXPORT {
	my ($element) = @_;

	return $element unless $element;
	return $element->previous_sibling;
}

sub previous_token :EXPORT {
	my ($element) = @_;

	return $element unless $element;
	return $element->previous_token;
}

sub remove_arguments :EXPORT {
	my ($element) = @_;

	remove_snext_sibling ($element) if is_list (snext_sibling ($element));
}

sub remove_current :EXPORT {
	$_->remove;
}

sub remove_invocant :EXPORT {
	my ($element) = @_;

	remove_sprevious_sibling ($element); # operator ->
	remove_sprevious_sibling ($element) if is_list (sprevious_sibling ($element)); # invocant's arguments
	remove_sprevious_sibling ($element); # invocant itself
}

sub remove_invokee :EXPORT {
	my ($element) = @_;

	$element = snext_sibling ($element) if is_list (snext_sibling ($element));

	remove_snext_sibling ($element); # operator ->
	remove_snext_sibling ($element); # invokee itself
	remove_snext_sibling ($element) if is_list (snext_sibling ($element));
}

sub remove_parameter :EXPORT {
	my (@parameters) = @_;

	return unless @parameters;

	if (is_operator_comma ($parameters[-1]->snext_sibling)) {
		# if is followed by any other parameters
		remove_snext_sibling ($parameters[-1]);
		remove_following_nonsignificant ($parameters[-1]);
	} elsif (is_operator_comma ($parameters[0]->sprevious_sibling)) {
		# if follows any other parameter
		remove_preceding_nonsignificant ($parameters[0]);
		remove_sprevious_sibling ($parameters[0]);
	} else {
		remove_following_nonsignificant ($parameters[-1]);
		remove_preceding_nonsignificant ($parameters[0]);
	}

	$_->remove for @parameters;
}

sub remove_preceding_nonsignificant :EXPORT {
	my ($element) = @_;

	return unless $element;
	while ($element->previous_sibling && ! $element->previous_sibling->significant) {
		$element->previous_sibling->remove;
	}
}

sub remove_following_nonsignificant :EXPORT {
	my ($element) = @_;

	return unless $element;
	while ($element->next_sibling && ! $element->next_sibling->significant) {
		$element->next_sibling->remove;
	}
}

sub remove_sprevious_sibling :EXPORT {
	my ($element) = @_;

	remove_preceding_nonsignificant ($element);
	$element->previous_sibling->remove;
}

sub remove_snext_sibling :EXPORT {
	my ($element) = @_;

	remove_following_nonsignificant ($element);
	$element->next_sibling->remove;
}

sub remove_variable_declaration :EXPORT {
	my ($element) = @_;

	$element = is_variable_declaration ($element);
	while ($element && $element->previous_sibling && is_whitespace ($element->previous_sibling)) {
		$element->previous_sibling->remove;
	}

	$element->remove;
}

sub snext_sibling :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return $element unless $element;
	return $element->snext_sibling;
}

sub sprevious_sibling :EXPORT {
	my ($element) = @_ ? @_ : ($_);

	return $element unless $element;
	return $element->sprevious_sibling;
}

sub split_list_old :EXPORT {
	my ($element) = @_;

	return unless is_ppi_structure_list ($element);
	my ($content) = grep { ! is_whitespace ($_) } $element->children;

	return unless $content;

	split_nodes_on_comma ($content->children);
}

sub split_list :EXPORT {
	my ($element) = @_;

	return unless is_ppi_structure_list ($element);
	my ($expression) = ppix_find ($element, where { is_ppi_statement_expression ($_) });

	my ($current, @elements);
	for ($expression->children) {
		if (is_operator_any_comma ($_)) {
			$current = undef;
			next;
		}

		if ($current || ! is_whitespace ($_)) {
			push @elements, $current = [] unless $current;
			push @$current, $_;
			next;
		}
	}

	for (@elements) {
		while (is_whitespace ($_->[-1])) {
			pop @$_;
		}
	}

	pop @elements if @elements && ! @{ $elements[-1] };

	@elements;
}

sub trim_whitespace :EXPORT {
	my (@elements) = @_;

	shift @elements while @elements && is_whitespace ($elements[0]);
	pop @elements while @elements && is_whitespace ($elements[-1]);

	@elements;
}

sub where (&) :EXPORT {
	bless shift, 'HPB::PPIx::Utils::Where';
}

sub invoke (&) :EXPORT {
	bless shift, 'HPB::PPIx::Utils::Invoke';
}

package HPB::PPIx::Utils::Where;
package HPB::PPIx::Utils::Invoke;

1;
