
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Term::Variable {
	use PPIx::Augment::Utils;

	use PPIx::Augment::Expression::Term::Variable;

	sub variable_name {
		return current
			if it_is_token_word or it_is_structure_block;

		return (current, next_sibling)
			if it_is_operator_bitwise_xor and its_next_sibling { it_is_token_word };

		return;
	}

	sub it_looks_like_variable_sigil {
		it_is_token_cast qr/[\$@%]/ or (it_is_operator_modulus and operator_isnt_expected);
	}

	sub it_looks_like_braced_variable {
		it_is_token_cast qr/[\$@%]/ and its_snext_sibling { it_is_structure_block };
	}

	sub it_looks_like_variable_name {
		return _ppi_true if it_is_token_word;
		return _ppi_true if it_is_token_number qr/^\d+$/;
		return _ppi_true if it_is_operator_bitwise_xor and its_next_sibling { it_is_token_word };
		return _ppi_false;
	}

	sub it_looks_like_variable_reference {
		return _ppi_true if it_looks_like_variable_name;
		return _ppi_false unless it_is_structure_block;

		my @children = significant_children;

		@children = significant_children $children[0]
			if @children == 1 && it_is_statement $children[0];

		local $_ = $children[0];

		return _ppi_false unless it_looks_like_variable_name;

		my @content = variable_name;

		return _ppi_true if @children && @children == @content;
		return _ppi_false;
	}

	sub _wrap_variable {
		current_replace_with (PPIx::Augment::Expression::Term::Variable::, $_, @_);
	}

	sub requires {
	}

	sub augment {
		my (undef, $document) = @_;

		ppix_transform $document    # $foo; @foo; %foo
			=> where { it_isnt_augmented_yet }
			=> where { it_is_token_symbol qr/^[\$%@*]\w+$/ }
			=> invoke { _wrap_variable }
			;

		ppix_transform $document    # $^H; %^H; (recognized by PPI)
			=> where { it_isnt_augmented_yet }
			=> where { it_is_token_magic qr/^[\$%@]\^\w$/ or it_is_token_magic qr/^[\$%@]\{\^\w+\}$/ }
			=> invoke { _wrap_variable }
			;

		ppix_transform $document    # $ foo; ${foo}; $ { foo }; $ ^H; ${ ^H }
			=> where { it_isnt_augmented_yet }
			=> where { it_looks_like_variable_sigil }
			=> where { its_snext_sibling { it_looks_like_variable_reference } }
			=> invoke { _wrap_variable following_insignificant, its_snext_sibling { variable_name } }
			;

	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Term::Variable - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Term::Variable::augment ($unused, $ppi_document)

=head1 DESCRIPTION

Wraps any kind of variable reference

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
