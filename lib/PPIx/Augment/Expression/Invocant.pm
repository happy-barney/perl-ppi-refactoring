
use v5.14;
use warnings;

package PPIx::Augment::Expression::Invocant {
	use parent qw[ PPIx::Augment::Expression::Lhs ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Expression::Invocant - Left-hand side of method invocation

=head1 INHERITANCE

	PPIx::Augment::Expression::Invocant
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
