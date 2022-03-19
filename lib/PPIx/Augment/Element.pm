
use v5.14;
use warnings;

package PPIx::Augment::Element {
	use parent qw[ PPI::Element ];

	use PPI::Document;
	use PPIx::Augment::Context::Package;

	sub PPI::Element::context_namespace {
		my ($self) = @_;

		my $element = $self;
		do {
			return $element->namespace if $element->isa (PPIx::Augment::Context::Package::);
			return '::' if $element->isa (PPI::Document::);
		} while $element = parent $element;

		return;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Element - Augmented PPI::Element

=head1 INHERITANCE

	PPIx::Augment::Element
		isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
