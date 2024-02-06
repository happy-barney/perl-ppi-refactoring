
use v5.14;
use warnings;

package PPIx::Augment::Utils::Common {
	use Attribute::Handlers;
	use parent Exporter::Tiny::;

	use PPI;
	use Ref::Util    qw (is_arrayref is_refref);
	use Scalar::Util qw (refaddr);

	use PPIx::Augment::Utils::Classification qw (it_is_element);

	use namespace::clean;

	our @EXPORT;

	sub _effective_arguments {
		my @prefix;
		push @prefix, @{ shift() }
			while is_arrayref ($_[0])
			;

		my $element = it_is_element ($_[0])
			? shift
			: is_refref ($_[0])
				? ${ shift() }->[0]
				: current ()
			;

		return ($element, @prefix, @_);
	}sub current ()                      :Exported {
		return $_;
	}sub Exported                        :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @EXPORT, *{$symbol}{NAME};
	}1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils::Accessor - PPI helpers

=head1 DESCRIPTION

Accessor functions helps to access data of L<PPI> elements, whether they are
accessible via method or not.

Every accessor function works with C<effective element>.

=head1 ACCESSOR FUNCTIONS

=head2 current ()

Convenient name to use instead of C<$_> to hide this implementation detail.

=head1 SEE ALSO

L<PPIx::Augment::Utils>

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
