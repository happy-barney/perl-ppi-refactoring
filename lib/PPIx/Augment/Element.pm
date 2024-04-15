
use v5.14;
use warnings;

package PPIx::Augment::Element {
	use parent qw (PPI::Element);

	use constant since_perl => v0.0;
	use constant until_perl => v5.39; # developed with current perl = v5.38

	sub content {
		return $_[0]->{content} // q ();
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Element - Augmented PPI class

=head1 INHERITANCE

    PPIx::Augment::Element
        isa PPI::Element

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Element>

=head1 METHODS

=head2 content

Similar to L<"PPI::Element->content"|PPI::Element/content> but
ensures that it never returns C<undef>.

Allows introduction of content-less marker elements.

=head2 since_perl

Perl version which introduced syntax represented by element.

=head2 until_perl

Perl version which disabled syntax represented by element.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
