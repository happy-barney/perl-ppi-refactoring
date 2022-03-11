
use v5.14;
use warnings;

package PPIx::Augment::Nodeset {
	use parent qw[ PPI::Node ];

	sub new {
		my ($class, @content) = @_;

		bless { children => \ @content }, $class;
	}

	sub add_element {
		die "You cannot add element into nodeset";
	}

	sub insert_before {
		die "You cannot insert element before nodeset";
	}

	sub __insert_before {
		die "You cannot insert element before nodeset";
	}

	sub insert_after {
		die "You cannot insert element after nodeset";
	}

	sub __insert_after {
		die "You cannot insert element after nodeset";
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Nodeset - Virtual PPI::Node representing set of nodes

=head1 INHERITANCE

	PPIx::Augment::Nodeset
		isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
