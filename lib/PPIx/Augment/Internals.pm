
use v5.14;
use warnings;

package PPIx::Augment::Internals {
	use parent qw (Exporter::Tiny);

	use Ref::Util qw ();

	our @EXPORT_OK = qw (
		flatten_array
		push_unique_string
	);

	sub ensure_isa {
		my $base = shift;
		my $into = shift // caller (2);

		no strict q (refs);

		push @{ qq (${into}::ISA) }, $base;
	}

	sub flatten_array {
		map { Ref::Util::is_arrayref ($_) ? flatten_array (@$_) : $_ } @_;
	}

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

PPIx::Augment::Internals - Some internal tools

=head1 DESCRIPTION

Some tools for internal usage, not intended for use outside of this module.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
