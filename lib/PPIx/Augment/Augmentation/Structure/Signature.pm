
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Structure::Signature {
	use parent qw[ PPIx::Augment::Augmentation ];

	use PPIx::Augment::Utils;

	use PPIx::Augment::Structure::Signature;

	my $AUGMENT_CLASS = PPIx::Augment::Structure::Signature::;

	sub augment {
		my (undef, $document) = @_;

		my @queue = ($document);

		ppix_transform
			=> where { it_is_token_prototype }
			=> where { current->prototype !~ qr/^[\s$@%*;\[\]&\\_+]*$/ }
			=> invoke {
				say "Found signature: ${\ current }";
			};
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Structure::Signature - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Structure::Signature->requires ($ppi_document)
	PPIx::Augment::Augmentation::Structure::Signature->augment ($ppi_document)

=head1 DESCRIPTION

Wraps every statement belonging to package into L<PPIx::Augment::Structure::Signature>
node. Package statement is always first child of given node.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
