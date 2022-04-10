
use v5.14;
use warnings;

package PPIx::Augment::Fix::Newline_Spaces {
	use PPIx::Augment::Utils;

	sub augment {
		my ($self, $document) = @_;

		ppix_transform $document
			=> where { it_is_token_whitespace qr/\n[^\n]/ }
			=> invoke {
				current_replace (
					create_token_new_line,
					create_token_whitespace (substr current_content, 1),
				);
			}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Fix::Magic_Cast - fix PPI issue

=head1 SYNOPSIS

	PPIx::Augment::Fix::Magic_Cast::fix ($unused, $ppi_document)

=head1 DESCRIPTION

	$$$foo;

is recognized by L<PPI> as magic token C<$$> followed by symbol token C<$foo>.
This fix splits such magic token into two cast tokens.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
