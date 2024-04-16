
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::Magic_Cast {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;

	use namespace::clean;

	sub how_to_augment {
		invoke {
			bless snext_sibling, PPI::Structure::Block::
				if its_snext_sibling { it_is_structure_subscript }
				;

			elements_replace current, [
				build_token_cast q ($),
				build_token_cast q ($),
			];
		}
	}

	sub what_to_augment {
		where { it_is_token_magic q ($$) },
		where { snext_sibling =~ qr (^[\$\{]) },
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::Magic_Cast

=head1 DESCRIPTION

When your code uses enough of scalar dereferences, L<PPI> recognizes
some of them as L<PPI::Token::Magic> C<$$> instead of L<PPI::Token::Cast>

    $$$foo;
    @$$$foo;
    $${}

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
