
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::PPI::Magic_Cast {

	use PPIx::Augment::Utils;
	use PPIx::Augment::Declare::Augmentation;

	use namespace::autoclean;

	declare augmentation
		=> where { it_is_token_magic q ($$) },
		=> where { snext_sibling =~ qr (^[\$\{]) },
		=> invoke {
			bless snext_sibling, PPI::Structure::Block::
				if its_snext_sibling { it_is_structure_subscript }
				;

			elements_replace current, [
				build_token_cast q ($),
				build_token_cast q ($),
			];
		};

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::PPI::Magic_Cast - Augment PPI tree

=head1 SYNOPSIS

    require PPIx::Augment::Augmentation::PPI::Magic_Cast;

    PPIx::Augment::->augment (
        $document,
        PPIx::Augment::Augmentation::PPI::Magic_Cast::
    );

=head1 DESCRIPTION

When your code uses certain scalar dereferences, L<PPI> recognises
them as L<PPI::Token::Magic> (C<$$>) instead of L<PPI::Token::Cast>.

For example:

    $$$foo;
    @$$$foo;
    $${}

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
