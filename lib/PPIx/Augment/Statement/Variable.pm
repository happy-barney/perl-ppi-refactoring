
use v5.14;
use warnings;

package PPIx::Augment::Statement::Variable {
	use parent qw[ PPIx::Augment::Statement::Expression PPI::Statement::Variable ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Statement::Variable - Augmented PPI::Statement::Variable

=head1 INHERITANCE

	PPIx::Augment::Statement::Variable
		isa PPIx::Augment::Statement::Expression
			isa PPIx::Augment::Statement
				isa PPIx::Augment::Node
					isa PPIx::Augment::Element
						isa PPI::Element
					isa PPI::Node
						isa PPI::Element
				isa PPI::Statement
					isa PPI::Node
						isa PPI::Element
			isa PPI::Statement::Expression
				isa PPI::Statement
					isa PPI::Node
						isa PPI::Element
		isa PPI::Statement::Variable
			isa PPI::Statement::Expression
				isa PPI::Statement
					isa PPI::Node
						isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
