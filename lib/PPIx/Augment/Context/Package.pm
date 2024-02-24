
use v5.14;
use warnings;

package PPIx::Augment::Context::Package {
	use parent qw (PPIx::Augment::Node);

	use PPIx::Augment::Utils qw (it_is_statement_package);

	use namespace::clean;

	sub namespace {
		my ($self) = @_;

		my $first_element = $self->first_element;

		return $first_element->namespace
			if it_is_statement_package ($first_element)
			;

		return q (main);
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Context::Package

=head1 INHERITANCE

    PPIx::Augment::Context::Package
        isa PPIx::Augment::Node
            isa PPIx::Augment::Element
            isa PPI::Node
                isa PPI::Element

=head1 DESCRIPTION

Introduced by augmentation L<PPIx::Augment::Augmentation::Context::Package>
provides parent with namespace for each element.

=head1 METHODS

=head2 namespace

Returns name of namespace this context represents.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
