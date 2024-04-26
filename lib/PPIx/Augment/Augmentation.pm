
use v5.14;
use warnings;

package PPIx::Augment::Augmentation {

	use Ref::Util;

	use PPIx::Augment::Utils qw (ppix_search ppix_transform);

	use PPIx::Augment::Internals qw (flatten_array);

	sub _effective_augment;

	use namespace::clean;

	sub _effective_augment {
		my (@list) = @_;

		return $list[0]
			if Ref::Util::is_plain_hashref ($list[0])
			;

		return { q () => $list[0] }
			if Ref::Util::is_plain_arrayref ($list[0])
			;

		return { q () => \ @list };
	}

	sub analyze {
		my ($self, $document) = @_;

		my $what_to_augment = _effective_augment ($self->what_to_augment ($document));

		return
			map { ppix_search $document, flatten_array ($what_to_augment->{$_}) }
			sort keys %$what_to_augment
			;
	}

	sub augment {
		my ($self, $document) = @_;

		my $what = _effective_augment ($self->what_to_augment ($document));
		my $how  = _effective_augment ($self->how_to_augment ($document));

		my $rv = 0;
		for my $key (keys %$what) {
			$rv += ppix_transform $document
				=> flatten_array ($what->{$key})
				=> flatten_array ($how->{$key})
			;
		}

		return $rv;
	}

	sub requires {
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation - Base class for augmentations of PPI documents

=head1 DESCRIPTION

=head1 METHODS

=head2 what_to_augment

Should return L<PPIx::Augment::Utils/where (&)|where (&)> expression
describing elements which has to be augmented.

=head2 how_to_augment

Should return L<PPIx::Augment::Utils/invoke (&)|invoke (&)> expression(s)
describing how element should be augmented.

=head2 analyze ($document)

Method called by L<PPIx::Augment>.

Be default it runs L<PPIx::Augment::Utils/ppix_find|ppix_find> with
L</_what_to_augment> as its argument.

=head2 augment ($document)

Method called by L<PPIx::Augment>.

Be default it runs L<PPIx::Augment::Utils/ppix_transform|ppix_transform>
with L</_what_to_augment> and L</_how_to_augment> as its arguments.

=head2 what_to_augment ($document)

Should return L<PPIx::Augment::Utils/where (&)|where (&)> expression(s)
describing how element should be augmented.

=head2 requires

Default: empty list

List of augmentations (full package names) expected to be executed
before applying this one.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This file is part of L<PPIx::Augment> distribution.

L<PPIx::Augment> distribution is distributed under Artistic Licence 2.0.

=cut
