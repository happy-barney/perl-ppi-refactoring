
use v5.14;
use warnings;

package PPIx::Refactoring::veure::test_controller_api {
	use PPIx::Augment::Utils;
	use namespace::clean;
	use Carp::Always;

	my %use_statement_extend_namespaces = map { $_ => 1 } qw[
		base
		parent
		Test::Class::Moose
	];sub exclude_files {
	}sub exclude_files_regexp {
		state $regex = do { join q ('|'), map qr/(?:\Q$_\E)/, exclude_files };
	}sub process_parameters {
	}sub refactoring {
		my ($context, $document, @parameters) = @_;

		my $parameters = process_parameters (@parameters);

		return 0
			if $document->filename =~ exclude_files_regexp;

		ppix_refactor
			=> where  { search_problems ($context, $document, $parameters) }
			=> invoke { repair_problems ($context, $document, $parameters) }
			;

		return 1;
	}sub repair_problems {
	}sub search_problems {
		my ($context, $document, $parameters) = @_;

		return ppi_false unless 
	}sub search_statement_extend {
		my ($document, $namespace) = @_;

		ppix_find $document
			=> where {
				return ppi_false
					unless context_namespace eq $namespace;
				return $use_statement_extend_namespaces{$_->namespace}
					if it_is_use_statement;

				return ppi_false
					unless it_is_statement;

				my @children = children;
				return ppi_true
					if it_is_token_word $children[0], { content => q ('extends') };

				shift @children
					if it_is_token_word $children[0], { content => q ('our') };

				shift @children
					while it_is_insignificant $children[0];

				return ppi_true
					if it_is_token_symbol $children[0], { content => q ('@ISA') };

				return ppi_false;
			}
			;
	}1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring::veure::test_controller_api - Veure refactoring

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

Test::YAFT distribution is distributed under Artistic Licence 2.0.

=cut

