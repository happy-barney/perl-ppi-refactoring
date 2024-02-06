
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Statement::Inherits::From {
	use parent qw[ PPIx::Augment::Augmentation ];

	use PPIx::Augment::Utils;
	use PPI::Singletons '%_PARENT';
	use Scalar::Util    qw{refaddr};

	use List::MoreUtils qw[ part ];

	use PPIx::Augment::Context::Package;

	my $AUGMENT_CLASS = PPIx::Augment::Context::Package::;

	sub augment {
		my (undef, $document) = @_;

		ppix_transform
			=> where { it_is_use_statement { module => qr/^(?:base|parent)$/ } }
			=> where { 0 }
			;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Context::Package - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Context::Package->requires ($ppi_document)
	PPIx::Augment::Augmentation::Context::Package->augment ($ppi_document)

=head1 DESCRIPTION

Wraps every statement belonging to package into L<PPIx::Augment::Context::Package>
node. Package statement is always first child of given node.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
