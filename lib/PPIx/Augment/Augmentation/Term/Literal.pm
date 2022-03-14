
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Term::Literal {
	use PPIx::Augment::Utils;

	use PPIx::Augment::Expression::Term::Literal;
	use PPIx::Augment::Fix::New_Octal_Numbers;

	sub requires {
		my (undef, $document) = @_;

		&PPIx::Augment::Fix::New_Octal_Numbers::fix;
	}

	sub augment {
		my (undef, $document) = @_;

		ppix_transform $document
			=> where { ! its_parent { it_is_augmented } }
			=> where { it_is_token_number || it_is_token_quote || it_is_token_quotelike }
			=> invoke {
				my $expression = PPIx::Augment::Expression::Term::Literal::->new;
				$expression->add_element ($_->clone);

				current_replace ($expression);

				$expression;
			}
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Term::Literal - Improve PPI document

=head1 SYNOPSIS

	PPIx::Augment::Augmentation::Term::Literal::augment ($unused, $ppi_document)

=head1 DESCRIPTION

Wraps literal values

=head2 term

Return literal value element.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
