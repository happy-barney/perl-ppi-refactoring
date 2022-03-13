
use v5.14;
use warnings;

package PPIx::Augment::Fix::New_Octal_Numbers {
	use PPIx::Augment::Utils;

	sub fix {
		my ($self, $document) = @_;

		ppix_transform $document
			=> where { it_is_token_number "0" }
			=> where { next_sibling =~ qr/^[oO][\d_]+$/ }
			=> invoke {
				current_replace_with (
					PPI::Token::Number::Octal::,
					current,
					next_sibling,
				);
			}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Fix::New_Octal_Numbers - fix PPI issue

=head1 SYNOPSIS

	PPIx::Augment::Fix::New_Octal_Numbers::fix ($unused, $ppi_document)

=head1 DESCRIPTION

Recognizes new octal number syntax

	0o777

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
