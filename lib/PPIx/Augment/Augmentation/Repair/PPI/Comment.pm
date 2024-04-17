
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::Comment {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Utils;

	my $re_newline    = qr (\n$);
	my $re_whitespace = qr (^\s+);

	use namespace::clean;

	sub how_to_augment {
		return +{
			newline    => invoke {
				content_remove $re_newline;
				insert_after [ build_newline ];
			},
			whitespace => invoke {
				my $content = content_remove $re_whitespace;
				insert_before [ build_token_whitespace $content ];
			},
		};
	}

	sub what_to_augment {
		return +{
			newline    => where { it_is_token_comment $re_newline },
			whitespace => where { it_is_token_comment $re_whitespace },
		}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::Comment - Augment PPI tree

=head1 SYNOPSIS

    PPIx::Augment->augment ($document, PPIx::Augment::Augmentation::Repair::PPI::Comment::);

=head1 DESCRIPTION

For every affected comment

=over

=item it extracts leading indentation into extra token

=item it extracts tailing C<\n> into extra token

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
