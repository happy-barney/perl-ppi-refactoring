
use v5.14;
use warnings;

package PPIx::Augment::Expression::Term::Do::Block {
	use parent qw[ PPIx::Augment::Expression::Term ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Expression::Term::Do::Block - do BLOCK

=head1 INHERITANCE

	PPIx::Augment::Expression::Term::Do::Block
		isa PPIx::Augment::Expression::Term
			isa PPIx::Augment::Expression
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

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
