
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Term::Anonymous {
	use PPIx::Augment::Utils;

	use PPIx::Augment::Expression::Term::Anonymous::Arrayref;
	use PPIx::Augment::Expression::Term::Anonymous::Coderef;
	use PPIx::Augment::Expression::Term::Anonymous::Hashref;

	sub requires {
	}

	sub augment {
		my (undef, $document) = @_;

		ppix_transform $document
			=> where { it_isnt_augmented_yet }
			=> where { it_is_structure_constructor '[]' }
			=> invoke {
				current_replace_with (
					PPIx::Augment::Expression::Term::Anonymous::Arrayref::,
					current,
				);
			}
			;

		ppix_transform $document
			=> where { it_isnt_augmented_yet }
			=> where { it_is_structure_constructor '{}' }
			=> invoke {
				current_replace_with (
					PPIx::Augment::Expression::Term::Anonymous::Hashref::,
					current,
				);
			}
			;

		ppix_transform $document
			=> where { it_isnt_augmented_yet }
			=> where { it_is_token_word 'sub' and its_snext_sibling { it_is_structure_block } }
			=> invoke {
				current_replace_with (
					PPIx::Augment::Expression::Term::Anonymous::Coderef::,
					current,
					following_insignificant,
					snext_sibling
				);
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
