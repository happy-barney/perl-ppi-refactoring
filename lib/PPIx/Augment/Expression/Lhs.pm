
use v5.14;
use warnings;

package PPIx::Augment::Expression::Lhs {
	use parent qw[ PPIx::Augment::Expression ];

	sub augment {
		return &PPIx::Augment::Expression::_augment_sprevious_sibling;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Expression::Lhs - Left-hand side of binary operation

=head1 INHERITANCE

	PPIx::Augment::Expression::Lhs
		isa PPIx::Augment::Expression
			isa PPIx::Augment::Statement::Expression
				isa PPIx::Augment::Statement
					isa PPI::Augment::Node
						isa PPI::Augment::Element
				isa PPI::Statement::Expression
					isa PPI::Statement
						isa PPI::Node
							isa PPI::Element

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
