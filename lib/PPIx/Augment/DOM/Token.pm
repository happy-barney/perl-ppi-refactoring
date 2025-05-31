
use v5.14;
use warnings;

package PPIx::Augment::DOM::Token {
	use parent qw (
		PPIx::Augment::DOM::Element
		PPI::Token
	);

	use mro q (c3);

	use PPI v1.278;
	use Scalar::Util;

	use constant PPI_CLASS         => q (PPI::Token);
	use constant VALIDATION_REGEXP => undef;
	use constant SUBCLASSES        => (
		q (PPIx::Augment::DOM::Token::Number),
		q (PPIx::Augment::DOM::Token::Quote),
		q (PPIx::Augment::DOM::Token::Symbol),
	);

	sub Identify {
		my ($class, $element) = @_;

		my $identified_class = $class->next::method ($element);

		return $identified_class
			if $identified_class
			&& $identified_class->VALIDATION_REGEXP
			&& $element->content =~ qr (^ ${\ $identified_class->VALIDATION_REGEXP } $)x
			;

		return;
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Token - Augmented PPI token element

=head1 INHERITANCE

=over

=item PPIx::Augment::DOM::Token

=over

=item L</PPIx::Augment::DOM::Element>

=back

=item L</PPI::Token>

=over

=item L</PPI::Element>

=back

=back

=head1 CONSTANTS

=head2 VALIDATION_REGEXP

    package PPIx::Augment::DOM::Token::Number::Octal {
        use constant VALIDATION_REGEXP => qr (\b 0 ([oO]? [0-7]+ \b )x;
    }

A regular expression that must match the element's content for successful identification.
When undefined (as in this base class), no content validation is performed.

=head1 STATIC METHODS

=head2 Identify

    CLASS->Identify ($element);

Extends the parent's L<PPIx::Augment::DOM::Element/Identify> method by adding content validation.

After the parent method positively identifies an element, this method additionally validates
that the element's content matches the L</VALIDATION_REGEXP> (if defined). The element is
only considered identified if both the parent identification succeeds and the content
validation passes.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and distributed under the same terms as the distribution itself.

=cut
