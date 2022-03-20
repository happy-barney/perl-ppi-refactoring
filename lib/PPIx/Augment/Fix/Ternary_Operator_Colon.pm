
use v5.14;
use warnings;

package PPIx::Augment::Fix::Ternary_Operator_Colon {
	use PPIx::Augment::Utils;

	sub augment {
		my ($self, $document) = @_;

		ppix_transform $document
			=> where { it_is_token_label }
			=> where { its_sprevious_sibling { it_is_operator } }
			=> invoke {
				my ($word, $whitespace, $colon) = current_content =~ m/^(\w+)(\s*)(:)$/;

				current_replace (
					create_token_word       $word,
					create_token_whitespace $whitespace,
					create_token_operator   $colon,
				);
			}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Fix::Ternary_Operator_Colon - fix PPI issues

=head1 SYNOPSIS

	PPIx::Augment::Fix::Ternary_Operator_Colon::fix ($unused, $ppi_document)

=head1 DESCRIPTION

When ternary operator's colon is preceeded by word then PPI recognizes
this word as a label

Example of affected code:

	$condition ? true : false;
	$condition ? JSON->true : JSON->false;

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
