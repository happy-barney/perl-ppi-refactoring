
use v5.14;
use warnings;

package PPIx::Augment {
	use PPI;
	use Safe::Isa;

	sub new {
		my ($class, @args) = @_;

		return $class->augment (@args);
	}

	sub augment {
		my ($self, $source) = @_;

		$source = PPI::Document::->new ($source)
			unless $source->$_isa (PPI::Document::);

		for my $augmentation ($self->augmentations) {
			$augmentation->requires ($source) if $augmentation->can ('requires');
			$augmentation->augment ($source);
		}

		$source;
	}

	sub augmentations {
		+(
		)
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment - Improve structure of PPI document

=head1 DESCRIPTION

Fix some bugs and improve structre of PPI documents

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

Test::YAFT distribution is distributed under Artistic Licence 2.0.

=cut
