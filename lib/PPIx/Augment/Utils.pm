
use v5.14;
use warnings;

package PPIx::Augment::Utils {
	use PPIx::Augment::Internals::Exporter;

	use PPI v1.278;
	use Scalar::Util;

	sub _process_args_invoke {
		my @invoke =
			grep { $_->isa (CLASS_INVOKE) }
			grep { Ref::Util::is_blessed_coderef ($_) }
			@_
			;

		return undef
			unless @invoke
			;

		return sub {
			&$_ for @invoke;
			return 1;
		};
	}

	sub _process_args_via {
		my ($via) =
			grep { $_->isa (CLASS_VIA) }
			grep { Ref::Util::is_blessed_coderef ($_) }
			@_
			;

		$via //= via { elements };

		return $via;
	}

	sub _process_args_where {
		my @where =
			grep { $_->$_isa (CLASS_WHERE) }
			map  { Scalar::Util::blessed ($_) $_ : &where ($_) }
			grep { Ref::Util::is_coderef ($_) }
			@_
			;

		return undef
			unless @where
			;

		return sub {
			my $result = ppi_include;

			for my $callback (@list) {
				last
					unless $result &&= &$callback
					;
			}

			return $result;
		};
	}

	sub ppix_search                     :Exported(traversal) {
		my $element = &element;
		my $where   = &_process_args_where;
		my $invoke  = &_process_args_invoke;
		my $via     = &_process_args_via;

		my $return_first  = defined wantarray && ! wantarray;
		my $return_at_all = defined wantarray;

		my @found;
		if ($where && it_is_element $start) {
			my @queue = ($start);

			while (my $current = shift @queue) {
				next
					unless defined (my $rv = $where->($element, $current))
					;

				if ($rv) {
					$invoke->($element, $current)
						if $invoke
						;

					return $current
						if $return_first
						;

					push @found, $current
						if $return_at_all
						;
				}

				unshift @queue, $via->($element, $current);
			}
		}

		return no_element
			if $return_first
			;

		return @found;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils - PPI processing utils

=head1 DESCRIPTION

Inspired by L<PPIx::Utils>, this module provides functions to make working
with L<PPI> easier (to write and read).
It provides similar functions for things L<PPIx::Augment> introduces.

Unless specified otherwise, every function is exported by default.

Exportable tags:

=over

=item C<:all>

Exports all exportable functions

=item C<:accessor>

Exports all L</ACCESSOR FUNCTIONS>

=item C<:builder>

Exports all L</BUILDER FUNCTIONS>

=item C<:classification>

Exports all L</CLASSIFICATION FUNCTIONS>

=item C<:default>

Exports all functions exported by default

=item C<:transformation>

Exports all L</TRANSFORMATION FUNCTIONS>

=item C<:traversal>

Exports all L</TRAVERSAL FUNCTIONS>

=back

=head1 GLOSSARY

=over

=item current element

An element currently processed by traversal functions, stored in C<$_>.

=item effective element

First argument of the function, if it is an instance of L<PPI::Element> or L</no element>,
L</current element> otherwise.

=item no element

A false value returned by an element accessor when there is no element to be returned.
The value is compatible with L<PPI> (as an empty string).

The value is an instance of a class that:

=over

=item evaluates to false

=item mimics PPI elements by returning safe false values

=back

=back

=head1 ACCESSOR FUNCTIONS

Helper functions to access various data of a L<PPI::Element> instance,
whether they are accessible via a direct method or have to be populated.

All accessor functions recognize C</no element> and return the corresponding value.

Unless specified otherwise, all functions work with L</effective element>.

=head2 current ()

Returns L</current element>.

=head2 element

Returns L</effective element>.

Assumed usage eg in classification function:

    # Using this syntax so shift will actually modify our arguments
    my $element = &element;

=head2 no_element ()

Returns value representing L<PPI> meaning "there is no element".

=head1 BUILDER FUNCTIONS

Helper functions to construct new L<PPI> / L<PPIx::Augment> elements,
usually taking decomposed values and merging them into the corresponding element / node.

=head1 CLASSIFICATION FUNCTIONS

Helper functions to identify an instance of L<PPI::Element>.

Unless specified otherwise, all functions work with L</effective element>.

=head1 TRANSFORMATION FUNCTIONS

Helper functions to modify L</effective element>.

=head1 TRAVERSAL FUNCTIONS

Helper functions to navigate through documents / elements.

=head2 ppix_search

	my @elements = ppix_search $element
		=> where  { ... condition 1 ... }
		=> where  { ... condition 2 ... }
		=> invoke { ... }
		=> invoke { ... }
        => via    { elements }
		;

Extended version of L<PPI::Node> methods C<find> and C<find_first>,
designed to be easier to use.

=over

=item effective element

The function works with L</effective element>.

The function automatically sets L</current element> before evaluating each condition / invoke.

=item Conditions and traversal

The default condition, when none is specified, is to exclude all elements.

The function searches C<elements> instead of C<children> by default.
See L</via (&)> for more.

The function accepts only subroutine conditions or L</where (&)> clauses.
Multiple conditions can be provided (combined using logical C<and>).

The function can invoke custom code on each found element via L</invoke (&)> clauses.
The return value of such code is ignored.

=item Return value

The function's return value recognises C<wantarray>;
in list context, it returns all found elements (or an empty list);
in scalar context, it returns only the first found element (or L</no element>).

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
