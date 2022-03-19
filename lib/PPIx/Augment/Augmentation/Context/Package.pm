
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Context::Package {
	use PPIx::Augment::Utils;

	use PPIx::Augment::Context::Package;

	sub requires {
	}

	sub augment {
		my (undef, $document) = @_;

		ppix_transform $document
			=> where { it_isnt_augmented_yet }
			=> where { it_is_statement_package }
			=> where { its_last_element { it_is_structure_block } }
			=> invoke {
				current_replace_with (PPIx::Augment::Context::Package::, current);
			}
			;

		ppix_transform $document
			=> where { it_isnt_augmented_yet }
			=> where { it_is_statement_package }
			=> where { its_last_element { ! it_is_structure_block } }
			=> invoke {
				my $element = PPIx::Augment::Context::Package->new;
				current_insert_before ($element);

				while (1) {
					move_next_sibling ($element, $element);
					my $next_sibling = $element->next_sibling;
					last unless $next_sibling;
					next unless it_is_statement_package $next_sibling;
					last unless it_is_structure_block $next_sibling->last_element;
				}
			}
			;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Term::Do::Block - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Term::Do::Block::augment ($unused, $ppi_document)

=head1 DESCRIPTION

Wraps

	do { ... }

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
