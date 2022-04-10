
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use Attribute::Handlers;
	use Exporter qw[ import ];
	use PPI;
	use PPI::Singletons;
	use PPIx::Utils qw[];
	use Ref::Util qw[];
	use Safe::Isa;
	use Scalar::Util qw[];

	use PPIx::Augment::Context::Package;

	our (@EXPORT, @EXPORT_OK, %EXPORT_TAGS);

	# Reimplementing of Exporter::Attributes as far as it requires 5.16
	sub Exported :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT, *{$symbol}{NAME};
	}

	sub Exportable :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT_OK, *{$symbol}{NAME};
		if (Ref::Util::is_arrayref ($data)) {
			push @{ $EXPORT_TAGS{$_} //= [] }, *{$symbol}{NAME}
				for @$data;
		}
	}

	my $CLASS_INVOKE = 'PPIx::Augment::Utils::Invoke';
	my $CLASS_WHERE  = 'PPIx::Augment::Utils::Where';

	sub current ();
	sub ppi_false ();
	sub ppi_false_dont_descent ();
	sub ppi_true ();

	sub _create_token {
		my ($class, @content) = @_;
		my $content = join '', grep defined, @content;

		return unless length ($content // '');

		return $class->new ($content);
	}

	sub _effective_accessor {
		my ($method) = shift;
		my ($element) = _effective_arguments (@_);

		return '' unless $element->$_isa (PPI::Element::);
		return $element->$method;
	}

	sub _effective_arguments {
		my @prefix;
		push @prefix, @{ shift() } while Ref::Util::is_arrayref ($_[0]);

		my $element = $_[0]->$_isa (PPI::Element::) ? shift
			: Ref::Util::is_refref ($_[0])          ? ${ shift() }->[0]
			: $_
			;

		return ($element, @prefix, @_);
	}

	sub _it_condition {
		my ($element, $condition) = @_;

		return ppi_true unless defined $condition;

		my $method = 'content';
		if (Ref::Util::is_plain_hashref ($condition)) {
			($method, $condition) = %$condition;
			$method = __PACKAGE__->can ($method)
				if __PACKAGE__->can ($method) && ! $element->can ($method);
		}

		my $value = $element->$method;

		return scalar $value =~ $condition
			if Ref::Util::is_regexpref ($condition);

		return $condition->($value)
			if Ref::Util::is_coderef ($condition);

		return $value eq $condition;
	}

	sub _it_conditions {
		my ($element, @conditions) = @_;

		for my $condition (@conditions) {
			return ppi_false unless _it_condition ($element, $condition);
		}

		return ppi_true;
	}

	sub _it_is {
		my ($element, $class, @conditions) = _effective_arguments @_;

		return ppi_false unless $element->$_isa ($class);
		return _it_conditions ($element, @conditions);
	}

	sub _its_where {
		my ($method, $code) = @_;

		return ppi_false
			unless current->$_isa (PPI::Element::);

		my $element = current->$method;

		return ppi_false
			unless $element->$_isa (PPI::Element::);

		local $_ = $element;

		$code->();
	}

	sub _process_invoke {
		my (@list) = grep $_->$_isa ($CLASS_INVOKE), @_;

		return unless @list;

		return sub {
			for my $callback (@list) { $callback->(@_) }
			return 1;
		};
	}

	sub _process_where {
		my (@list) = grep { $_->$_isa ($CLASS_WHERE) || Ref::Util::is_plain_coderef ($_) } @_;

		return unless @list;

		return sub {
			my $result = ppi_true;
			for my $callback (@list) { $result &&= $callback->(@_) or last }
			return $result;
		};
	}

	sub _remove_from_parent {
		my ($element) = @_;

		if ((my $index = child_index ($element)) > -1) {
			splice( @{$element->parent->{children}}, $index, 1 );
			delete $PPI::Singletons::_PARENT{Scalar::Util::refaddr ($element)};
		}

		$element;
	}

	sub child_index                     :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		if ($element && $element->parent) {
			my $key = Scalar::Util::refaddr ($element);

			my $children = $element->parent->{children};
			for my $index (0 .. $#$children) {
				return $index
					if Scalar::Util::refaddr ($children->[$index]) == $key
			}
		}

		return -1;
	}

	sub children                        :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		return unless it_is_node ($element);
		return $element->children;
	}

	sub clone_indent                    :Exported :Exportable(builder) {
		my ($element) = _effective_arguments @_;

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

	sub content                         :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments (@_);

		return '' unless it_is_element ($element);
		return $element->content;
	}

	sub context_namespace               :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		while ($element) {
			return $element->namespace if it_is (\ [$element], PPIx::Augment::Context::Package::);
			$element = $element->parent;
		}

		return;
	}

	sub context_namespace_element       :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		while ($element) {
			return $element if it_is (\ [ $element ], PPIx::Augment::Context::Package::);
			$element = $element->parent;
		}

		return '';
	}

	sub create_statement                :Exported :Exportable(builder) {
		return element_create (PPI::Statement:: => @_);
	}

	sub create_statement_include        :Exported :Exportable(builder) {
		element_create (PPI::Statement::Include:: => @_);
	}

	sub create_structure                :Exported :Exportable(builder) {
		my ($class, $token, @content) = @_;

		my $start  = create_token_structure ($token);
		my $finish = create_token_structure ($token =~ tr/([{/)]}/r);

		my $element = $class->new ($start);
		element_add ($element, @content);
		$element->{finish} = $finish;

		return $element;
	}

	sub create_structure_block          :Exported :Exportable(builder) {
		return create_structure (PPI::Structure::Block::, '{', @_);
	}

	sub create_token_cast ($)           :Exported :Exportable(builder) {
		return _create_token (PPI::Token::Cast::, @_);
	}

	sub create_token_new_line ()        :Exported :Exportable(builder) {
		create_token_whitespace ("\n");
	}

	sub create_token_number_octal ($)   :Exported :Exportable(builder) {
		return _create_token (PPI::Token::Number::Octal::, @_);
	}

	sub create_token_operator ($)       :Exported :Exportable(builder) {
		return _create_token (PPI::Token::Operator::, @_);
	}

	sub create_token_semicolon          :Exported :Exportable(builder) {
		return create_token_structure (';');
	}

	sub create_token_structure ($)      :Exported :Exportable(builder) {
		return _create_token (PPI::Token::Structure::, @_);
	}

	sub create_token_word ($)           :Exported :Exportable(builder) {
		return _create_token (PPI::Token::Word::, @_);
	}

	sub create_token_word_list          :Exported :Exportable(builder) {
		my ($content) = @_;
		$content = "qw" . $content unless $content =~ m/^qw/;

		my $token = PPI::Token::QuoteLike::Words->new ('qw');
		$token->set_content ($content);
		$token->{sections} = [ { position => 2, size => length ($content) - 2 } ];

		return $token;
	}

	sub create_token_whitespace ($)     :Exported :Exportable(builder) {
		return _create_token (PPI::Token::Whitespace::, @_);
	}

	sub current ()                      :Exported :Exportable(accessor) {
		return $_;
	}

	sub current_content ()              :Exported :Exportable(accessor) {
		return content ();
	}

	sub current_insert_before           :Exported :Exportable(transformation) {
		return element_insert_before (current (), @_);
	}

	sub current_replace                 :Exported :Exportable(transformation) {
		return element_replace ([current], @_);
	}

	sub element_add                     :Exported :Exportable(transformation) {
		my ($element, @content) = @_;

		for (@content) {
			next unless $_->$_isa (PPI::Element::);
			my $add = $_;
			if ($_->parent) {
				$add = $_->clone;
			}

			$element->add_element ($add);
		}

		return $element;
	}

	sub element_create                  :Exported :Exportable(builder) {
		my ($class, @content) = @_;

		my $element = $class->new;

		element_add ($element, @content);
	}

	sub element_insert_after            :Exported :Exportable(transformation) {
		my $element = shift;

		return unless it_is_element ($element);

		# skip PPI's restrictions
		$element->__insert_after ($_) for @_;

		return;
	}

	sub element_insert_before           :Exported :Exportable(transformation) {
		my $element = shift;

		return unless it_is_element ($element);

		# skip PPI's restrictions
		$element->__insert_before ($_) for @_;

		return;
	}

	sub element_remove                  :Exported :Exportable(transformation) {
		$_->remove for grep $_->$_isa (PPI::Element::), @_;
	}

	sub element_remove_statement        :Exported :Exportable(transformation) {
		my ($e) = @_;

		$e->previous_sibling->remove if it_is_token_indentation (previous_sibling ($e));

		if (! sprevious_sibling ($e) && it_is_followed_by_empty_line ($e)) {
			$e->next_sibling->remove;
		} elsif (! snext_sibling ($e) && it_is_preceeded_by_empty_line ($e)) {
			$e->previous_sibling->remove;
		} elsif (it_is_preceeded_by_empty_line ($e) && it_is_followed_by_empty_line ($e)) {
			$e->previous_sibling->remove;
		}

		if (it_is_token_new_line (next_sibling ($e))) {
			$e->next_sibling->remove;
		} elsif (it_is_token_new_line (previous_sibling ($e))) {
			$e->previous_sibling->remove;
		}

		$e->remove;
	}

	sub element_replace                 :Exported :Exportable(transformation) {
		my ($element, @with_elements) = @_;

		$element = [ $element ] unless Ref::Util::is_plain_arrayref ($element);
		my ($head) = grep $_->$_isa (PPI::Element::), @$element;

		return unless it_is_element ($head);

		for my $with_element (@with_elements) {
			next unless it_is_element ($with_element);
			_remove_from_parent ($with_element);
			$head->__insert_before ($with_element);
		}

		element_remove (@$element);

		return;
	}

	sub elements_wrap                   :Exported :Exportable(transformation) {
		my ($class, @elements) = @_;

		my $parent   = $elements[0]->parent;
		my $position = child_index ($elements[0]);

		my $wrap = $class->new;
		$wrap->{children} = \ @elements;

		# reparent
		$PPI::Singletons::_PARENT{Scalar::Util::refaddr $wrap} = $parent;

		for my $child (@elements) {
			$PPI::Singletons::_PARENT{Scalar::Util::refaddr $child} = $wrap;
		}

		splice @{$parent->{children}}, $position, scalar @elements, $wrap;

		return $wrap;
	}

	sub find_filename                   :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		while (1) {
			return '' unless $element;
			return $element->filename if $element->$_isa (PPI::Document::);
			$element = $element->parent;
		}
	}

	sub following_insignificant         :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		my @following_insignificant;

		while (it_is_insignificant ($element->next_sibling)) {
			push @following_insignificant, $element->next_sibling;
			$element = $following_insignificant[-1];
		}

		return @following_insignificant;
	}

	sub invoke (&)                      :Exported :Exportable(traversal) {
		return bless $_[0], $CLASS_INVOKE;;
	}

	sub it_is                           :Exported :Exportable(classification) {
		return _it_is (@_);
	}

	sub it_is_document                  :Exported :Exportable(classification) {
		return it_is ([PPI::Document::], @_);
	}

	sub it_is_element                   :Exported :Exportable(classification) {
		return it_is ([PPI::Element::], @_);
	}

	sub it_is_followed_by_empty_line    :Exported :Exportable(classification) {
		my ($element) = _effective_arguments @_;

		while ($element) {
			my $next_sibling = $element->next_sibling;
			last unless $next_sibling;

			if (it_is_token_new_line ($next_sibling)) {
				return ppi_true if it_is_token_new_line (\ [$next_sibling->next_sibling]);
				last;
			}

			last unless it_is_insignificant (\ [$next_sibling], qr/\s+/);

			$element = $next_sibling;
		}

		return ppi_false;
	}

	sub it_is_insignificant             :Exported :Exportable(classification) {
		return it_is_element ([{ significant => sub { ! $_[0] } }], @_);
	}

	sub it_is_method_call               :Exported :Exportable(classification) {
		my ($element, @conditions) = _effective_arguments @_;

		return ppi_false
			unless 0
			|| PPIx::Utils::is_method_call ($element)
			|| it_is_token_symbol (\ [$element])
			|| it_is_token_word (\ [$element])
			|| it_is_token_cast (\ [$element], '$')
			;

		return _it_conditions ($element, @conditions);
	}

	sub it_is_node                      :Exported :Exportable(classification) {
		return it_is ([PPI::Node::], @_);
	}

	sub it_is_operator                  :Exported :Exportable(classification) {
		return it_is ([PPI::Token::Operator::], @_);
	}

	sub it_is_operator_arrow            :Exported :Exportable(classification) {
		it_is_operator (['->'], @_);
	}

	sub it_is_operator_colon            :Exported :Exportable(classification) {
		it_is_operator ([':'], @_);
	}

	sub it_is_operator_fat_arrow        :Exported :Exportable(classification) {
		it_is_operator (['=>'], @_);
	}

	sub it_is_package_declaration       :Exported :Exportable(classification) {
		my ($element, @conditions) = _effective_arguments @_;

		return ppi_false unless it_is_statement_package (\ [$element], @conditions);
		return ppi_false if     it_is_structure_block ($element->last_element);
		return ppi_true;
	}

	sub it_is_package_definition        :Exported :Exportable(classification) {
		my ($element, @conditions) = _effective_arguments @_;

		return ppi_false unless it_is_statement_package (\ [$element], @conditions);
		return ppi_false unless it_is_structure_block (\ [$element->last_element]);
		return ppi_true;
	}

	sub it_is_preceeded_by_empty_line   :Exported :Exportable(classification) {
		my ($element) = _effective_arguments @_;

		while ($element) {
			my $previous_sibling = $element->previous_sibling;
			last unless $previous_sibling;

			if (it_is_token_new_line ($previous_sibling)) {
				return ppi_true if it_is_token_new_line (\ [$previous_sibling->previous_sibling]);
				last;
			}

			last unless it_is_insignificant (\ [$previous_sibling], qr/\s+/);

			$element = $previous_sibling;
		}

		return ppi_false;
	}

	sub it_is_significant               :Exported :Exportable(classification) {
		return it_is_element ([{ significant => sub { $_[0] } }], @_);
	}

	sub it_is_statement                 :Exported :Exportable(classification) {
		return it_is ([PPI::Statement::], @_);
	}

	sub it_is_statement_include         :Exported :Exportable(classification) {
		return it_is ([PPI::Statement::Include::], @_);
	}

	sub it_is_statement_package         :Exported :Exportable(classification) {
		return it_is ([PPI::Statement::Package::], @_);
	}

	sub it_is_statement_sub             :Exported :Exportable(classification) {
		return it_is ([PPI::Statement::Sub::], @_);
	}

	sub it_is_statement_variable        :Exported :Exportable(classification) {
		return it_is ([PPI::Statement::Variable::], @_);
	}

	sub it_is_structure_block           :Exported :Exportable(classification) {
		return it_is ([PPI::Structure::Block::], @_);
	}

	sub it_is_structure_list            :Exported :Exportable(classification) {
		return it_is ([PPI::Structure::List::], @_);
	}

	sub it_is_token_attribute           :Exported :Exportable(classification) {
		return it_is [PPI::Token::Attribute::], @_;
	}

	sub it_is_token_cast                :Exported :Exportable(classification) {
		return it_is [PPI::Token::Cast::], @_;
	}

	sub it_is_token_indentation         :Exported :Exportable(classification) {
		my ($element) = _effective_arguments @_;

		return ppi_false unless it_is_token_whitespace (\ [$element]);
		return ppi_false if it_is_token_new_line (\ [$element]);
		return ppi_true;
	}

	sub it_is_token_label               :Exported :Exportable(classification) {
		return it_is [PPI::Token::Label::], @_;
	}

	sub it_is_token_magic               :Exported :Exportable(classification) {
		return it_is [PPI::Token::Magic::], @_;
	}

	sub it_is_token_new_line            :Exported :Exportable(classification) {
		it_is_token_whitespace (["\n"], @_);
	}

	sub it_is_token_number              :Exported :Exportable(classification) {
		return it_is ([PPI::Token::Number::], @_);
	}

	sub it_is_token_prototype           :Exported :Exportable(classification) {
		return it_is ([PPI::Token::Prototype::], @_);
	}

	sub it_is_token_quote               :Exported :Exportable(classification) {
		return it_is ([PPI::Token::Quote::], @_);
	}

	sub it_is_token_quotelike_words     :Exported :Exportable(classification) {
		return it_is ([PPI::Token::QuoteLike::Words::], @_);
	}

	sub it_is_token_structure           :Exported :Exportable(classification) {
		return it_is ([PPI::Token::Structure::], @_);
	}

	sub it_is_token_symbol              :Exported :Exportable(classification) {
		return it_is ([PPI::Token::Symbol::], @_);
	}

	sub it_is_token_whitespace          :Exported :Exportable(classification) {
		it_is ([PPI::Token::Whitespace::], @_);
	}

	sub it_is_token_word                :Exported :Exportable(classification) {
		it_is ([PPI::Token::Word::], @_);
	}

	sub it_is_use_statement             :Exported :Exportable(classification) {
		return it_is_statement_include ([{ type => 'use' }], @_);
	}

	sub its_parent (&)                  :Exported :Exportable(traversal) {
		return _its_where parent => @_;
	}

	sub its_snext_sibling (&)           :Exported :Exportable(traversal) {
		return _its_where snext_sibling => @_;
	}

	sub its_sprevious_sibling (&)       :Exported :Exportable(traversal) {
		return _its_where sprevious_sibling => @_;
	}

	sub next_sibling                    :Exported :Exportable(accessor) {
		return _effective_accessor next_sibling => @_;
	}

	sub next_siblings                   :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		return unless $element->next_sibling;

		my $index = child_index ($element);
		return if $index < 0;

		$index ++;
		my $total = $#{ $element->parent->{children} };
		return if $index > $total;

		return @{ $element->parent->{children} }[$index .. $total];
	}

	sub ppi_false ()                    :Exported :Exportable(traversal) {
		return 0;
	}

	sub ppi_false_dont_descent ()       :Exported :Exportable(traversal) {
		return undef;
	}

	sub ppi_true ()                     :Exported :Exportable(traversal) {
		return 1;
	}

	sub ppix_find                       :Exported :Exportable(traversal) {
		my ($element, @params) = @_;

		my $where = _process_where (@params);

		return unless $where && $element->$_isa (PPI::Element::);
		return @{ $element->find (sub {
			local $_ = $_[1];
			my $rv = eval { $where->(@_) };
			say "died: $@" if $@;
			return $rv;
		}) || [] };
	}

	sub ppix_process                    :Exported :Exportable(traversal){
		my ($element, @params) = @_;

		my $where  = _process_where  (@params);
		my $invoke = _process_invoke (@params);

		return 0 unless $where && $invoke && $element->$_isa (PPI::Element::);
		return scalar map { $invoke->() } ppix_find $element, $where;
	}

	sub ppix_transform                  :Exported :Exportable(traversal) {
		my ($element, @params) = @_;

		my $where  = _process_where (@params);
		my $invoke = _process_invoke (@params);

		return 0 unless $where && $invoke && it_is_element ($element);

		my $rv = 0;
		my %visited;

		RESTART:
		my @current = ($element);
		while (@current) {
			my $current = shift @current;
			next unless $current;

			my $refaddr = Scalar::Util::refaddr ($current);
			my $parent = $current->parent;

			unless (exists $visited{$refaddr}) {
				$visited{$refaddr} = 1;

				local $_ = $current;
				# when $current is replaced it losts its parent reference
				if ($where->()) {
					$rv++;
					$invoke->();

					# Invoke can modify tree, so restart search after each
					# Multi-process is guarded by %visited
					goto RESTART;
				}
			}

			unshift @current, $current->children
				if it_is_node ($current);
		}

		return $rv;
	}

	sub previous_sibling                :Exported :Exportable(accessor) {
		my ($element) = _effective_arguments @_;

		return '' unless $element;
		return $element->previous_sibling;
	}

	sub search_variable_scope           :Exported :Exportable(accessor) {
		my ($variable) = @_;

		my @result;
		my $node = $variable->parent->snext_sibling;
		while ($node) {
			push @result, $node;
			$node = $node->snext_sibling;
		}

		return @result;
	}

	sub snext_sibling                   :Exported :Exportable(accessor) {
		return _effective_accessor snext_sibling => @_;
	}

	sub snext_siblings                  :Exported :Exportable(accessor) {
		grep { $_->significant } next_siblings @_;
	}

	sub sprevious_sibling               :Exported :Exportable(accessor) {
		return _effective_accessor sprevious_sibling => @_;
	}

	sub where (&)                       :Exported :Exportable(traversal) {
		return bless $_[0], $CLASS_WHERE;
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

Unless specified otherwise every function is exported by default.

=head1 GLOSSARY

=over

=item current element

Tranversal / processing functions populates C<$_> with element they are currently
processing.

=item effective element

When this term is used it means that function will use I<current element>
when its first argument is not an instance of L<PPI::Element>.

=back

=head1 ACCESSOR FUNCTIONS

Accessor functions alone are exportable via C<:accessor> tag.

=head2 child_index

Returns index of I<effective element> in its parent's children list.

Returns -1 when I<effective element> doesn't have a parent.

=head2 children

Returns children list of I<effective element>.

Returns empty list when I<effective element> is not an instance of L<PPI::Node>.

=head2 content

Returns content of I<effective element> when it is an instance of L<PPI::Element>.
Returns empty string otherwise.

=head2 context_namespace

Returns namespace of package I<effective element> belongs to.
returns C<undef> when there is no package statement available.

=head2 context_namespace_element

Returns L<PPIx::Augment::Context::Package> I<effective element> belongs to.
returns C<empty element> when there is no package statement available.

=head2 current ()

Returns I<current element>.

Hides implementation details behind name expressing intention.

=head2 current_content ()

Returns content of I<current element> when it is an instance of L<PPI::Element>.
Returns empty string otherwise.

Hides implementation details of I<current element> behind name expressing intention.

=head2 next_sibling

Returns next sibling of I<effective element> when it is an instance of L<PPI::Element>.
Returns empty string otherwise.

Unlike plain method it can be applied also on non-PPI-elements.

=head2 snext_sibling

Returns snext sibling of I<effective element> when it is an instance of L<PPI::Element>.
Returns empty string otherwise.

Unlike plain method it can be applied also on non-PPI-elements.

=head1 BUILDER FUNCTIONS

Builder functions alone are exportable via C<:builder> tag.

Builder functions hind boring stuff of building PPI elements and
always treats arguments as expected content.

=head2 create_statement

	create_statement @content;

Creates new instance of L<PPI::Statement> and adds C<@content> as its children.
When content element has parent, clones it.

=head2 create_structure

	create_structure $class, $start_token, @content;
	create_structure 'PPI::Structure::Block', '{', ...;

Creates new instance of C<$class> and adds C<@content> as its children.
When content element has parent, clones it.

=head2 create_structure_block

	create_structure_block @content;

Calls C<create_structure> with parameters required to build L<PPI::Structure::Block>

When content element has parent, clones it.

=head2 create_token_cast ($)

Builds L<PPI::Token::Cast> instance with provided content.

Content must be defined and not empty.

Builder doesn't validates content to actually match any cast operator.

=head2 create_token_number_octal ($)

Builds L<PPI::Token::Number::Octal> instance with provided content.

Content must be defined and not empty.

Builder doesn't validates content to actually match octal number.

=head2 create_token_new_line ()

Builds L<PPI::Token::Whitespace> containing single new line.

=head2 create_token_operator ($)

Builds L<PPI::Token::Operator> instance with provided content.

Content must be defined and not empty.

Builder doesn't validates content to actually match any operator.

=head2 create_token_structure ($)

Builds L<PPI::Token::Structure> instance with provided content.

Content must be defined and not empty.

Builder doesn't validates content to actually match any structure token.

=head2 create_token_word ($)

Builds L<PPI::Token::Word> instance with provided content.

Content must be defined and not empty.

Builder doesn't validates content to actually match a word.

=head2 create_token_whitespace ($)

Builds L<PPI::Token::Whitespace> instance with provided content.

Content must be defined and not empty.

Builder doesn't validates content to actually match a whitespace.

=head2 element_create

	element_create $class, @content;

Creates new instance of C<$class> and add C<@content> as its children.
When content element has parent, clones it.

=head1 CLASSIFICATION FUNCTIONS

Classification functions alone are exported via C<:classification> tag.

Every classification works with I<effective element>.

Every classification, when returning false, doesn't prohibit descend.

Every classification function accepts optional conditions.
Multiple conditions are evaluated as logical and.

=over

=item undef

Ignore condition (evaluates as true).

=item scalar

Element's content must be equal to the given string

=item regex

Element's content must match given regex

=item coderef

Coderef takes element's content as a single argument

=item single key hashref

Use different method (passed as a key) then C<content> to access value to compare.

Method name can be either method name of tested element or L<PPIx::Augment::Utils>
accessor.

=back

=head2 it_is

	it_is 'PPI::Element';
	it_is $element, 'PPI::Element';
	it_is 'PPI::Element', ... conditions ...;

Test whether effective element is an instance of given class.

=head2 it_is_document

Test whether I<effective element> is an instance of L<PPI::Document>.

=head2 it_is_element

Test whether I<effective element> is an instance of L<PPI::Element>.

=head2 it_is_followed_by_empty_line

Test whether I<effective element> is followed by empty line

=head2 it_is_insignificant

Test whether effective element is insignificant.

=head2 it_is_node

Test whether I<effective element> is an instance of L<PPI::Node>
(ie. has C<children>)

=head2 it_is_operator

Test whether I<effective element> is an instance of L<PPI::Token::Operator>.

=head2 it_is_package_declaration

Test whether I<effective element> is a package statement without block.

=head2 it_is_package_definition

Test whether I<effective element> is a package-block statement.

=head2 it_is_preceeded_by_empty_line

Test whether I<effective element> is preceeded by empty line

=head2 it_is_significant

Test whether effective element is significant.

=head2 it_is_statement

Test whether I<effective element> is an instance of L<PPI::Statement>.

=head2 it_is_statement_package

Test whether I<effective element> is an instance of L<PPI::Statement::Package>.

=head2 it_is_structure_block

Test whether I<effective element> is an instance of L<PPI::Structure::Block>.

=head2 it_is_token_label

Test whether I<effective element> is an instance of L<PPI::Token::Label>.

=head2 it_is_token_magic

Test whether I<effective element> is an instance of L<PPI::Token::Magic>.

=head2 it_is_token_new_line

Test whether I<effective element> is an instance of L<PPI::Token::Whitespace>
containing single C<\n>.

=head2 it_is_token_number

Test whether I<effective element> is an instance of L<PPI::Token::Number>.

=head2 it_is_token_whitespace

Test whether I<effective element> is an instance of L<PPI::Token::Whitespace>.

=head1 HELPER FUNCTIONS

=head1 TRANSFORMATION FUNCTIONS

Exportable via C<:transformation> tag.

Fuctions related to PPI document transformation.

=head2 current_insert_before

Inserts provided elements before I<current element>.

Bypasses PPI's restrictions.

=head2 element_add

	element_add $element, @content;

Adds new children into C<$element>.
When content element has parent, clones it.

=head2 element_insert_before

Inserts provided elements before it's first argument.

Bypasses PPI's restrictions.

=head2 element_remove

	element_remove $e1, $e2, ...;

Remove elements;

=head2 element_replace

	element_replace [$e1, $e2], $new1, $new2;

Replace elements (given as 1st argument) with another element(s).

=head1 TRAVERSAL FUNCTIONS

Exportable via C<:traversal> tag.

=head2 invoke (&)

	invoke { ... your code ... }

Helper function to provide code to invoke on found element.

Function is executed with I<current element> populated.

=head2 its_sprevious_sibling (&)

When I<current element> has C<sprevious_sibling> then it evaluates provide
code and returns its return value.

Otherwise returns C<ppi_false ()>.

=head2 ppi_false ()

Constant value, when returned from comparison function, current element will
excluded and processing will continue with its children.

=head2 ppi_false_dont_descent ()

Constant value, when returned from comparison function, current element will
excluded, as well as its children.

=head2 ppi_true ()

Constant value, when returned from comparison function, current element will
be included.

=head2 ppix_find

	my @result = ppix_find $document
		=> where { ... condition 1 ... }
		=> where { ... condition 2 ... }
		;

Similar to L<PPI>'s find, but

=over

=item it returns a list

=item it passes current element as C<$_> as well

=item it supports only coderef or L<where> conditions

=item it supports multiple conditions (evaluated using logical C<and>)

=back

When C<$element> is not a L<PPI::Element> or there is no condition specified,
it returns empty list.

=head2 ppix_transform

	ppix_transform $element
		=> where { ... }
		=> invoke { ... }
		;

Searches all children of C<$element> matching all I<where clauses> and invoking
all I<invoke clauses> on each of them.

After each I<invoke> it reevaluates whole tree again, ignoring already visited.

Returns number of found elements.

=head2 where (&)

	where { ... your condition ... }

Helper function to provide code to test current element.

Function is executed with I<current element> populated.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
