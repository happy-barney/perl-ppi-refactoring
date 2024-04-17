
use v5.14;
use warnings;

package PPIx::Refactoring {
	use parent q (PPIx::Augment::Augmentation);

	sub new {
		bless {}, shift;
	}

	sub how_to_augment  { shift->how_to_refactor (@_) }
	sub refactor        { shift->augment (@_) }
	sub what_to_augment { shift->what_to_refactor (@_) }

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring - Base class for changing PPI document structur

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
