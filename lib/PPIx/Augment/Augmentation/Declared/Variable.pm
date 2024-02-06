
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Declared::Variable {
	use parent PPIx::Augment::Augmentation::;

#	use PPIx::Augment::Utils;
#	use PPIx::Augment::Declared::Variable;
#
#	use namespace::clean;
#
#	sub _find_single_declared_variables {
#		my ($self, $document) = @_;
#
#		ppix_find $document
#			=> where { it_is_token_symbol qr (^ [%$@] )x }
#			=> where { its_parent { it_is_structure_block || it_is_document } }
#			;
#	}
#
#	sub _find_single_declared_variables {
#		my ($self, $document) = @_;
#
#		ppix_find $document
#			=> where { dont_descend_if { it_is (PPIx::Augment::Declared::Variable) } }
#			=> where { it_is_token_symbol qr (^ [%$@] )x }
#			=> where { its_parent { it_is_statement_expression } }
#			=> where { its_parent { its_parent { its_parent { it_is_statement_variable } } } }
#			;
#	}
#
#	sub _find_for_iterator {
#	}
#
	sub augment {
#		my ($self, $document) = @_;
#
#		bless $_, PPIx::Augment::Declared::Variable::
#			for
#				$self->_find_single_declared_variables ($document),
#				$self->_find_list_declared_variables ($document),
#				;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Fix::Magic_Cast - fix PPI issue

=head1 DESCRIPTION

	$$$foo;

is recognized by L<PPI> as magic token C<$$> followed by symbol token C<$foo>.
This fix splits such magic token into two cast tokens.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
