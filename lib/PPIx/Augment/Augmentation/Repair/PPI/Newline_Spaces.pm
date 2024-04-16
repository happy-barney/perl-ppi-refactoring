
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;

	use namespace::clean;

	sub how_to_augment {
		invoke {
			elements_replace
				[ current ],
				[
					map { build_token_whitespace $_ }
					grep { length }
					split q ((\n)), content
				];
		};
	}

	sub what_to_augment {
		where { it_is_token_whitespace qr (\n) },
		where { length (content) > 1 },
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces - Augment PPI tree

=head1 SYNOPSIS

    PPIx::Augment->augment ($document, PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces::);

=head1 DESCRIPTION

Split L<PPI::Token::Whitespace> tokens so when it contains new line,
it is solely character it contains.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
