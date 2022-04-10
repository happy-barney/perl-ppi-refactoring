
use v5.14;
use warnings;

package PPIx::Augment::Context::Package {
	use parent qw[ PPI::Node ];
	use PPI;

	sub namespace {
		my ($self) = @_;

		my $first = $self->first_element;

		return $first->namespace
			if $first && $first->isa (PPI::Statement::Package::);

		return '';

	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Context::Package - Wrap every package content into single element

=head1 INHERITANCE

	PPIx::Augment::Context::Package
		isa PPI::Node
			isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
