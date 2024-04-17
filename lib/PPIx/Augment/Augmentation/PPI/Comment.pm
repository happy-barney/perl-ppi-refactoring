
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::PPI::Comment {
	use PPIx::Augment::Utils;
	use PPIx::Augment::Declare::Augmentation;

	use namespace::autoclean;

	my $re_whitespace = qr (^\s+);
	declare augmentation
		=> leading_whitespace
		=> where { it_is_token_comment $re_whitespace }
		=> invoke {
			my $content = content_remove $re_whitespace;
			insert_before [ build_token_whitespace $content ];
		};

	my $re_newline    = qr (\n$);
	declare augmentation
		=> trailing_newline
		=> where { it_is_token_comment $re_newline }
		=> invoke {
			content_remove $re_newline;
			insert_after [ build_newline ];
		};

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::PPI::Comment - Augment PPI tree

=head1 SYNOPSIS

    require PPIx::Augment::Augmentation::PPI::Comment;

    PPIx::Augment::->augment (
        $document,
        PPIx::Augment::Augmentation::PPI::Comment::
    );

=head1 DESCRIPTION

For every affected comment, this augmentation

=over

=item extracts leading indentation into an extra token

=item extracts trailing newline into an extra token

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
