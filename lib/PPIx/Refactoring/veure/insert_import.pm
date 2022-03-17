
use v5.14;
use warnings;

package PPIx::Refactoring::veure::insert_import {
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub insert_statement_before {
		my ($context, $document, $module, @symbols) = @_;

		my @packages = ppix_find $document => where { it_is_statement_package };

		die "Unimplemented - multitple package declarations in ${\ find_filename $document }"
			if @packages > 1;

		my @imports = ppix_find $document => where { it_is_statement_use };

		die "Unimplemented - no imports yet in ${\ find_filename $document }"
			unless @imports;

		my ($insert_before) = grep { it_is_statement_use 'Veure::Moo' } @imports;
		if ($insert_before) {
			$insert_before = $insert_before->previous_sibling
				while it_is_token_whitespace ($insert_before->previous_sibling);
		} else {
			$insert_before = $imports[-1]->next_sibling;
		}

		return $insert_before;
	}

	sub build_statement_indent {
		my ($context, $document, $module, @symbols) = @_;

		my @imports = ppix_find $document => where { it_is_statement_use };

		return clone_indent ($imports[0]);
	}

	sub refactoring {
		my ($context, $document, $module, @symbols) = @_;

		my $insert_before = insert_statement_before ($context, $document, $module, @symbols);
		my @indent = build_statement_indent ($context, $document);

		my $functions = join ' ', @symbols;
		my $import = create_statement_include (
			create_token_word ('use'),
			create_token_whitespace (' '),
			create_token_word ($module),
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
