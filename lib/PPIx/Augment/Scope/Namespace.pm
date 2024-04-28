
use v5.14;
use warnings;

package PPIx::Augment::Scope::Namespace {
	use parent qw (PPIx::Augment::Scope);

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

PPIx::Augment::Scope::Package

=head1 INHERITANCE

=head1 DESCRIPTION

Appearing in element's parent list it provides universal access
to namespace current element is declared.

=head1 METHODS

=head2 namespace

Returns name of namespace this context represents.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
