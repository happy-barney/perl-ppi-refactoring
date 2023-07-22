
use v5.14;
use warnings;

package PPIx::Augment::Declared::Variable {
	use parent q (PPI::Token::Symbol);

	sub scope {
		my ($self) = @_;

		ppix_find_parent $self
			=> where { it_is_structure_block || it_is_document }
			;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Declared::Variable - Augmented PPI::Document

=head1 INHERITANCE

	PPIx::Augment::Declared::Variable
		isa PPI::Token::Symbol
			isa PPI::Token
				isa PPI::Element

=head1 DESCRIPTION

There are multiple PPI structures of declared variable.
This augmentation marks them so they can be easily searched for later

=head1 METHODS

=head2 scope

Returns node in which this variable is visible.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
