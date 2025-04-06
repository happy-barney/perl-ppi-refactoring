
use v5.14;
use warnings;

package PPIx::Augment::Internals {
	use parent qw (Exporter::Tiny);

	our @EXPORT_OK = qw (
		push_unique_string
	);

	sub push_unique_string (\@;@) {
		my $push_into = shift;

		my %exists;
		@exists{@$push_into} = ();

		push @$push_into, grep { ! exists $exists{$_} } @_;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Internals - Internal utils

=head1 DESCRIPTION

Some utils for internal usage, not intended for use outside of this module.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
