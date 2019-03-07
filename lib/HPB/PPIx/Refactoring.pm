
use strict;
use warnings;
use feature 'say';

package HPB::PPIx::Refactoring;

use Exporter qw[ import ];
use PPIx::Utils qw[ :classification :language :traversal ];
use HPB::PPIx::Utils;
use Ref::Util;
use Safe::Isa;

our @EXPORT;
our @EXPORT_OK;

use Attribute::Handlers;

sub EXPORT :ATTR(CODE,BEGIN) {
    my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

	push @EXPORT, *{$symbol}{NAME};
	push @EXPORT_OK, *{$symbol}{NAME};
}

sub expression_until_sibling :EXPORT {
	my ($from, $to) = @_;

	my @list = ($from);
	while (1) {
		my $next = next_sibling ($list[-1]);
		return unless $next;
		last if $next == $to;
		push @list, $next;
	}

	return @list;
}

sub lookup_function_call :EXPORT {
	my ($name) = @_;

	where {
		is_ppi_token_word ($_, $name)
			&& is_function_call ($_)
	};
}

sub invoke_replace_with_uri_for :EXPORT {
	my ($uri_for, $key) = @_;

	invoke {
		my $function_call = $_;
		my ($parameter) = parse_arg_list ($function_call);

		$function_call->insert_before (create_token_symbol ('$self'));
		$function_call->insert_before (create_operator_arrow);
		$function_call->insert_before (create_token_word ($uri_for));

		my @symbols = grep $_->significant, @$parameter;

		$symbols[-1]->insert_after (create_token_whitespace (' '))
			unless is_whitespace (next_token ($symbols[-1]));

		$symbols[0]->insert_before (create_token_whitespace (' '))
			unless is_whitespace (previous_token ($symbols[0]));

		$symbols[0]->insert_before (create_token_word ($key));
		$symbols[0]->insert_before (create_token_whitespace (' '));
		$symbols[0]->insert_before (create_operator_fat_comma);
		$symbols[0]->insert_before (create_token_whitespace (' '));

		$function_call->remove;
	}
}

sub find_index_of_property_as_argument :EXPORT {
	my ($element) = @_;

	my $index = 0;
	for my $parameter (find_function_call_arguments (find_caller_method ($element))) {
		my @elements = grep $_->significant, @$parameter;
		next if @elements < 3;
		return $index if $elements[2] eq $element;
	} continue {
		$index++;
	}

	return -1;
}

sub find_possible_named_argument :EXPORT {
	my ($element) = @_;

	my $comma = sprevious_sibling ($element);
	next unless is_operator_any_comma ($comma);

	my $key = sprevious_sibling ($comma);

	return $key if is_ppi_token_word ($key);
	return;
}

sub named_argument_value :EXPORT {
	my ($element) = @_;

	return $element->content if is_ppi_token_word ($element);
	return;
}

sub find_property_as_argument :EXPORT {
	my ($element, $method) = @_;

	ppix_find ( $element, where {
		is_method_call_name ($_, $method)
			&& is_method_parameter ($_)
			&& find_caller_invocant ($_, find_invocant ($_))
	});
}

sub find_property_as_argument_of_module_method :EXPORT {
	my ($element, $method) = @_;

	my %declared_functions = find_declared_functions_map ($element);

	grep { exists $declared_functions{ find_caller_method ($_) } }
		find_property_as_argument ($element, $method)
		;
}

sub find_variables_initialized_from_property :EXPORT {
	my ($element, $property) = @_;

	ppix_find ($element, where {
		is_ppi_statement_variable ($_->parent)
			&& is_symbol ($_)
			&& is_token_my ($_->sprevious_sibling)
			&& ppix_find ($_->parent, where {
				is_method_call_name ($_, $property)
					&& is_not_invocant ($_)
					&& method_invocant ($_) eq '$self'
					&& ! (
						is_ppi_statement_expression ($_->parent)
							&& is_list ($_->parent->parent)
					)
				}),
		},
	);
}

sub eliminate_property_as_argument :EXPORT {
	my ($document, $method) = @_;

	my %declared_functions = find_declared_functions_map ($document);

	my %method_to_clear;
	my %method_call_to_clear;

	my @method_call = find_property_as_argument_of_module_method ($document, $method);
	for my $method_call (@method_call) {
		my $caller_method = find_caller_method ($method_call);
		my $index = find_index_of_property_as_argument ($method_call);

		$method_to_clear{$caller_method} //= $index;
		push @{ $method_call_to_clear{$caller_method} //= [] }, $method_call;

		die "multiple arguments to remove: $method_to_clear{$caller_method}, $index",
			unless $method_to_clear{$caller_method} == $index;
	}

	for my $method_to_clear (sort keys %method_call_to_clear) {
		say "Method $method_to_clear is not module method" and next
			unless exists $declared_functions{$method_to_clear};

		my $index = $method_to_clear{$method_to_clear};

		my ($arguments) = ppix_find ($declared_functions{$method_to_clear}, \& is_ppi_statement_variable);
		my ($names) = ppix_find ($arguments, \& is_list);

		my @arguments = map [ grep $_->significant, @$_ ], split_list ($names);
		if (@arguments < $index + 2 || $arguments[1 + $index][0]->symbol_type ne '$') {
			say "argument $index not assigned to variable";
			next;
		}

		my $name = $arguments[1 + $index][0];

		my ($method_call) = @{ $method_call_to_clear{$method_to_clear} };
		my @expression = @{ (find_function_call_arguments (find_caller_method ($method_call)))[$index] };

		$arguments->insert_after (my $variable = create_statement_variable);
		$arguments->insert_after ($_->clone) for reverse find_expression_indent ($name);
		$variable->add_element (create_token_word ('my'));
		$variable->add_element (create_token_whitespace (' '));
		$variable->add_element (create_token_symbol ("$name"));
		$variable->add_element (create_token_whitespace (' '));
		$variable->add_element (create_operator_assign);
		$variable->add_element (create_token_whitespace (' '));
		$variable->add_element ($_->clone) for @expression;
		$variable->add_element (create_token_structure (';'));

		remove_parameter ($name);

		for my $method_call (@{ $method_call_to_clear{$method_to_clear} }) {
			my @parameters = parse_arg_list (find_caller_method ($method_call));
			remove_parameter (@{ $parameters[$index] });
		}
	}

	@method_call;
}

sub eliminate_property_variables :EXPORT {
	my ($element, $property) = @_;

	my @nodes = find_variables_initialized_from_property ($element, $property);

	for my $variable (@nodes) {
		my $scope = find_variable_scope ($variable);

		my @expression = find_variable_initialization_expression ($variable, $scope);

		for my $symbol (find_variable_usage ($variable, $scope)) {
			replace_element ($symbol, @expression);
		}

		remove_variable_declaration ($variable);
	}

	@nodes;
}

1;

