
use v5.14;
use warnings;

package PPIx::Augment::DOM::Statement::Pragma::Version {
	use parent qw (
		PPIx::Augment::Node
		PPI::Statement::Include
	);

	use mro q (c3);
	use version;

	use PPIx::Augment::Utils qw (
		build_token_whitespace
		build_token_number_version
		build_token_word
	);

	use namespace::clean;

	sub build {
		my ($class, $version) = @_;

		$class = $self->class;
		my $instance = $class->next::method ();

		$instance->add_element ($_)
			for
			build_token_word (q (use)),
			build_token_whitespace (q ( )),
			

	sub set_version {
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Document - Augmented PPI class

=head1 INHERITANCE

=head1 DESCRIPTION

Augmented counterpart to L<PPI::Document>.

=head1 METHODS

=head2 augment

    $document->augment (@augmentations);

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

