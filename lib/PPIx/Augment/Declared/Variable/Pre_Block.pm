
use v5.14;
use warnings;

package PPIx::Augment::Declared::Variable::Pre_Block {
	use parent q (PPIx::Augment::Declared::Variable);

	sub scope {
		my ($self) = @_;

		# TODO: find subsequent block
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Declared::Variable::Pre_Block - Augmented PPI::Document

=head1 INHERITANCE

	PPIx::Augment::Declared::Variable
		isa PPIx::Augment::Declared::Variable
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
