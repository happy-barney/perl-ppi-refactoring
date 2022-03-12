
use v5.14;
use warnings;

package PPIx::Augment::Structure::Given {
	use parent qw[ PPIx::Augment::Structure PPI::Structure::Given ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Structure::Given - Augmented PPI::Structure::Given

=head1 INHERITANCE

	PPIx::Augment::Structure::Given
		isa PPIx::Augment::Structure
			isa PPIx::Augment::Node
				isa PPIx::Augment::Element
					isa PPI::Element
				isa PPI::Node
					isa PPI::Element
			isa PPI::Structure
				isa PPI::Node
					isa PPI::Element
		isa PPI::Structure::Given
			isa PPI::Structure
				isa PPI::Node
					isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
