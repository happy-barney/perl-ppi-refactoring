
use v5.14;
use warnings;

package PPIx::Refactoring::veure::extend_imports {
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub refactoring {
		my ($context, $document, %params) = @_;
		my $module = $params{module};
		my @context = map +{ context_namespace => $_ }, grep $_, $params{context};
		my @imports = @{ $params{imports} };

		my @elements = ppix_find $document
			=> where { it_is_use_statement { module => $module }, @context }
			;

		return unless @elements;

		my ($argument) = my @arguments = $elements[-1]->arguments;

		die "Unimplemented - Module $module doesn't have exactly one argument (${\ find_filename $document }"
			if @arguments != 1;

		if ($argument->isa (PPI::Token::Quote::)) {
			my $word_list = create_token_word_list ("qw(${\ $argument->literal })");
			element_replace (
				$argument,
				$word_list,
			);

			$argument = $word_list;
		}

		unless ($argument->isa (PPI::Token::QuoteLike::Words::)) {
			PPI::Dumper->new ($argument)->print;
			die "Unimplemented - Module $module argument is not qw (${\ find_filename $document }";
		}

		my %already_imported = map { $_ => 1 } $argument->literal;

		my @missing = grep { ! $already_imported{$_} } @imports;
		return 0 unless @missing;

		my $content = $argument->content;
		my ($pad) = $argument->_section_content (0) =~ m/(\s+)/;
		$pad //= ' ';
		$content =~ s/(?=\s*.$)/$pad$_/ for @missing;

		$argument->set_content ($content);

		return 1;
	}

	1;
}
