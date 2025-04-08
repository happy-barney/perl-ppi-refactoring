
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::PPI::Newline_Spaces {
	use PPIx::Augment::Augmentation qw (
		declare
	);
	use PPIx::Augment::Utils qw (
		content
		create_token_whitespace
		current
		invoke
		it_is_token_whitespace
		replace_elements
		where
	);

	use namespace::clean;

	declare augmentation
		=> where  { it_is_token_whitespace qr (\n), qr (\s\s)s }
		=> invoke {
			replace_elements
				[ current ],
				[
					map { create_token_whitespace $_ }
					grep { length }
					split q ((\n)), content
				]
			}
		;

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::PPI::Newline_Spaces - Augment PPI document

=head1 SYNOPSIS

    PPIx::Augment->augment ($document, PPIx::Augment::Augmentation::PPI::Newline_Spaces::);

=head1 DESCRIPTION

Ensure that L<PPI::Token::Whitespace> token contains either single sequence treated as newline
or other whitespaces.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
