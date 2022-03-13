
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Cast_Block {
	use PPIx::Augment::Utils;

	sub augment {
		my (undef, $document) = @_;

		ppix_transform $document
			=> where { it_isnt_augmented_yet }
			=> where { it_is_token_cast }
			=> where { its_snext_sibling { it_is_structure_block } }
			=> where { ! its_parent { it_is_augmented } }
			=> invoke {
				my $expression = PPIx::Augment::Expression::Cast_Block->new;
				$expression->add_element ($_->clone);

				move_next_insignificant ($_ => $expression);
				move_next_sibling       ($_ => $expression);

				current_replace ($expression);
			}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Cast_Block - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Cast_Block::augment ($unused, $ppi_document)

=head1 DESCRIPTION

Treats sigil-braces expression as single PPI element

	$ { ... }
	${ ... }
	@{ ... }
	%{ ... }

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
