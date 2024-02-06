
use v5.14;
use warnings;

package PPIx::Refactoring::exporter::eliminate_inheritance {
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub it_is_statement_inherit_from {
		my ($from) = @_;

		return ppi_false
			unless it_is_use_statement { module => qr/^ (?: base | parent ) $/ };

		my @arguments = map { $_->literal } current->arguments;

		return ppi_true
			if grep { $_ eq $from }, @arguments;

		return ppi_false;
	}

	sub refactoring {
		my ($context, $document, %params) = @_;

		ppix_transform $document
			=> where { it_is_statement_inherit_from 'Exporter' }
			=> invoke {
				current_replace (
					create_statement_include (
						type => 'use',
						module => $from,
						arguments => create_token_quote_single ('import'),
					),
				);
			};
	}

	1;
}
