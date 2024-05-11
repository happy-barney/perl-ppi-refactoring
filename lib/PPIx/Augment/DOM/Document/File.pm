
use v5.14;
use warnings;

package PPIx::Augment::DOM::Document::File {
	use parent qw (
		PPIx::Augment::DOM::Document
		PPI::Document::File
	);

	use mro q (c3);

	use PPI::Document::File v1.278;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::DOM::Document::File - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Document::File>.

=head1 METHODS

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
