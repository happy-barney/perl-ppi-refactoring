
use v5.14;
use warnings;

package PPIx::Refactoring::veure::insert_import {
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub insert_statement_before {
		my ($context, $document, %params) = @_;

		my @packages = ppix_find $document => where { it_is_statement_package };

		die "Unimplemented - multitple package declarations in ${\ find_filename $document }"
			if @packages > 1 && ! $params{context};

		my @context = map +{ context_namespace => $_ }, grep $_, $params{context};
		my @imports = ppix_find $document => where { it_is_use_statement @context };

		die "Unimplemented - no imports yet in ${\ find_filename $document }"
			unless @imports;

		my ($insert_before) = grep { it_is_use_statement { module => 'Veure::Moo' } } @imports;
		if ($insert_before) {
			$insert_before = $insert_before->previous_sibling
				while it_is_token_whitespace ($insert_before->previous_sibling);
		} else {
			$insert_before = $imports[-1]->next_sibling;
		}

		return $insert_before;
	}

	sub build_statement_indent {
		my ($context, $document, $insert_before) = @_;

		unless (it_is_significant (\ [$insert_before])) {
			$insert_before =
				$insert_before->sprevious_sibling
				|| $insert_before->snext_sibling
				|| $insert_before
				;
		}

		return clone_indent ($insert_before);
	}

	sub refactoring {
		my ($context, $document, %params) = @_;

		my $insert_before = insert_statement_before ($context, $document, %params);
		my @indent = build_statement_indent ($context, $document, $insert_before);

		my $functions = join ' ', @{ $params{imports} };
		my $import = create_statement_include (
			create_token_word ('use'),
			create_token_whitespace (' '),
			create_token_word ($params{module}),
			create_token_whitespace (' '),
			create_token_word_list ("qw($functions)"),
			create_token_semicolon,
		);

		element_insert_before (
			$insert_before,
			$import,
		);

		element_insert_before (
			$import,
			create_token_new_line,
			@indent,
		);

		return 1;
	}

	1;
}
