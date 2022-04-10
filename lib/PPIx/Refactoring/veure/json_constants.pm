
use v5.14;
use warnings;

package PPIx::Refactoring::veure::json_constants {
	use PPIx::Augment::Utils;
	use namespace::clean;
	use Carp::Always;

	sub exclude_files {
		'/Veure/Util/Data.pm'
	}

	sub exclude_files_regexp {
		state $regex = do { join '|', map qr/(?:\Q$_\E)/, exclude_files };
	}

	sub refactoring {
		my ($context, $document, $method) = @_;

		return 0
			if $document->filename =~ exclude_files_regexp;

		my %imports;

		return unless ppix_transform $document
			=> where { it_is_token_word qr/^JSON/ }
			=> where { ! its_sprevious_sibling { it_is_operator_arrow } }
			=> where { its_snext_sibling { it_is_operator_arrow } }
			=> where { its_snext_sibling { its_snext_sibling { it_is_token_word $method } } }
			=> invoke {
				my $package = current;
				my $arrow   = $package->snext_sibling;
				my $method  = $arrow->snext_sibling;
				my $json_function = 'json_' . $method->content;

				$context->refactor ('veure::ensure-import' => (
					module  => 'Veure::Util::Data',
					context => context_namespace,
					imports => [ $json_function ],
				));

				current_insert_before (
					create_token_word ($json_function)
				);

				if (it_is_operator_fat_arrow ($method->snext_sibling)) {
					...;
				}

				element_remove (
					$package, following_insignificant ($package),
					$arrow, following_insignificant ($arrow),
					$method
				);
			}
		;

		return 1;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring - Basic framework for automated refactorings

=head1 DESCRIPTION

Fix some bugs and improve structre of PPI documents

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

Test::YAFT distribution is distributed under Artistic Licence 2.0.

=cut
