
use v5.14;
use warnings;

package PPIx::Augment::Document {
	use parent qw[ PPI::Document ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Node - Augmented PPI::Node

=head1 INHERITANCE

	PPIx::Augment::Document
		isa PPIx::Augment::Node
			isa PPIx::Augment::Element
				isa PPI::Element
			isa PPI::Node
				isa PPI::Element
		isa PPI::Document
			isa PPI::Node
				isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
