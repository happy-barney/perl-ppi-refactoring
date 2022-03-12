
use v5.14;
use warnings;

package PPIx::Augment::Statement::Include {
	use parent qw[ PPIx::Augment::Statement PPI::Statement::Include ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Statement::Include - Augmented PPI::Statement::Include

=head1 INHERITANCE

	PPIx::Augment::Statement::Include
		isa PPIx::Augment::Statement
			isa PPIx::Augment::Node
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Node
					isa PPI::Element
			isa PPI::Statement
				isa PPI::Node
					isa PPI::Element
		isa PPI::Statement::Include
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
