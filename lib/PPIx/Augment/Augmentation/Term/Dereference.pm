
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Term::Dereference {
	use PPIx::Augment::Utils;

	use PPIx::Augment::Expression::Term::Dereference;

	sub requires {
	}

	sub augment {
		my (undef, $document) = @_;


		ppix_transform_reverse $document
			=> where { its_parent { it_isnt_augmented_yet } }
			=> where { it_is_token_cast qr/^.$/ }
			=> where { its_snext_sibling {
				it_is_structure_block
					or it_is_augmented_dereference
					or it_is_augmented_variable
				}}
			=> invoke {
				current_replace_with (
					PPIx::Augment::Expression::Term::Dereference::,
					current,
					following_insignificant,
					snext_sibling
				)
			} ;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Expression::Reference - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Expression::Reference::augment ($unused, $ppi_document)

=head1 DESCRIPTION

Wraps referencing expressions as single PPI element: subscript, method call

	$foo{bar}
	$foo[bar]
	$foo(bar)
	$foo->{bar}
	$foo->[bar]
	$foo->(bar)
	$foo->bar

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
