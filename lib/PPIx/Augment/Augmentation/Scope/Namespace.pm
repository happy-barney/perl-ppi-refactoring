
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Scope::Namespace {
	use parent q (PPIx::Augment::Augmentation);

	use mro q (c3);

	use PPIx::Augment::Scope::Namespace;
	use PPIx::Augment::Utils qw (;
		where
		invoke
		it_is
		it_is_statement_package
		it_is_package_declaration
		elements_replace
		elements_wrap
	);


	sub _augment_elements {
		elements_wrap (PPIx::Augment::Scope::Namespace::, @_);
	}

	use namespace::clean;

	sub how_to_augment {
		invoke {
			_augment_elements (
				it_is_package_declaration
				? (current, next_siblings)
				: (current)
			)
		}
	}

	sub what_to_augment {
		where { it_is_statement_package || it
			&& ! it_is parent, PPIx::Augment::Scope::Namespace::
		},
	}

	sub analyze {
		my ($self, $document) = @_;
		return 1 + $self->next::method ($document);
	}

	sub augment {
		my ($self, $document) = @_;

		unless (it_is ($document, PPIx::Augment::Scope::Namespace::, $document->first_element)) {
			_augment_elements $document->children;
		}

		$self->next::method ($document);
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Scope::Namespace

=head1 DESCRIPTION

Ensures that every element in document has proper L<PPIx::Augment::Scope::Namespace>
amongst its parents.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
