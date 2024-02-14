
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Context_Package {
	use parent qw[ PPIx::Augment::Augmentation ];

	use PPIx::Augment::Utils;

	use PPIx::Augment::Context::Package;

	sub _augment_elements;
	sub _augment_package_declaration;
	sub _augment_package_definition;
	sub _it_is_augment_context_package;
	sub _it_is_unaugmented_package_statement;
	sub _it_isnt_package_definition;

	use constant _AUGMENT_CLASS => PPIx::Augment::Context::Package::;

	use namespace::clean;

	sub _augment_elements {
		elements_wrap (_AUGMENT_CLASS, @_);
	}

	sub _augment_package_declaration {
		my ($document) = @_;

		# eg: package FOO;
		ppix_transform $document
			=> where { _it_is_unaugmented_package_statement }
			=> where { it_is_package_declaration }
			=> invoke {
				_augment_elements (
					current,
					ppix_find_next_siblings current
						=> where { 1 || ! it_is_package_declaration }
				)
			}
	}

	sub _augment_package_definition {
		my ($document) = @_;

		# eg: package FOO { }
		ppix_transform $document
			=> where { _it_is_unaugmented_package_statement }
			=> where { it_is_package_definition }
			=> invoke {
				_augment_elements (
					current
				)
			}
		}

	sub _it_is_any_package_definition {
		return ppi_true
			if it_is_package_definition
			;

		return ppi_true
			if _it_is_augment_context_package
			&& it_is_package_definition current->statement_package
			;

		return ppi_false;
	}

	sub _it_is_augment_context_package {
		it_is [_AUGMENT_CLASS], @_;
	}

	sub _it_is_unaugmented_package_statement {
		it_is_statement_package
			&& its_parent { ! _it_is_augment_context_package }
			;
	}

	sub augment {
		my ($self, $document) = @_;

		_augment_package_declaration ($document);
		_augment_package_definition ($document);
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Context::Package - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment->augment (
		$document,
		PPIx::Augment::Augmentation::Context::Package::
	);

=head1 DESCRIPTION

Wraps every statement belonging to package into L<PPIx::Augment::Context::Package>
node. L<PPI::Statement::Package> node is always its first child.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
