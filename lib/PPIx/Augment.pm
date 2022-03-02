
use v5.14;
use warnings;

package PPIx::Augment {
	require PPIx::Augment::Elements;

	require PPIx::Augment::Augmentation::Rebless;
	require PPIx::Augment::Fix::Magic_Cast;
	require PPIx::Augment::Fix::New_Octal_Numbers;
	require PPIx::Augment::Fix::Ternary_Operator_Colon;

	require PPIx::Augment::Augmentation::Cast_Block;

	use PPIx::Augment::Token;
	use PPIx::Augment::Token::Operator::Arrow;
	use PPIx::Augment::Expression::Call::Method;

	require PPIx::Augment::Augmentation::Term::Anonymous;
	require PPIx::Augment::Augmentation::Term::Dereference;
	require PPIx::Augment::Augmentation::Term::Do_Block;
	require PPIx::Augment::Augmentation::Term::Literal;
	require PPIx::Augment::Augmentation::Term::Variable;
	require PPIx::Augment::Augmentation::Expression::Reference;

	our $VERBOSE = 0;
	our $TRACE = 0;

	sub verbose (&) {
		($VERBOSE || $TRACE) && say '[Augment] ', $_[0]->();
	}

	sub trace (&) {
		$TRACE && say '[Augment] ', '|> ', $_[0]->();
	}


	sub augment_operator {
		my ($self, $document) = @_;
		my %operators = (
			'->' => 'PPIx::Augment::Token::Operator::Arrow',
			'=>' => 'PPIx::Augment::Token::Operator::Fat_Comma',
			','  => 'PPIx::Augment::Token::Operator::Comma',
			'?'  => 'PPIx::Augment::Token::Operator::Question_Mark',
		);

		ppix_process $document
			=> where { is_operator }
			=> where { ! is_augmented }
			=> where { exists $operators{ content() } }
			=> invoke { bless $_, $operators{ content() } }
			;
	}

	sub augment_method_call {
		my ($self, $document) = @_;

		ppix_process $document
			=> where { is_operator_arrow }
			=> where { is_method_call snext_sibling }
			=> invoke { PPIx::Augment::Expression::Call::Method->new ($_) }
			;
	}

	sub augment_conditional_expression {
		my ($self, $document) = @_;

		ppix_process $document
			=> where { is_operator_question_mark }
			=> invoke {
				say "=> invoke ($_)";
				PPIx::Augment::Expression::Conditional->new ($_)
			}
			;
	}

	sub augment {
		my ($self, $document) = @_;

		&PPIx::Augment::Augmentation::Rebless::augment;

		&fix;

		verbose { "Organize document little bit better" };

		&$_ for grep { $_ } map { ($_->can ('requires'), $_->can ('augment')) } (
			PPIx::Augment::Augmentation::Term::Anonymous::,
			PPIx::Augment::Augmentation::Term::Dereference::,
			PPIx::Augment::Augmentation::Term::Do_Block::,
			PPIx::Augment::Augmentation::Term::Literal::,
			PPIx::Augment::Augmentation::Term::Variable::,
		);

		&augment_operator;
		&augment_method_call;
		&augment_conditional_expression;

		$document;
	}

	sub fix {
		my ($self, $document) = @_;

		verbose { "Fix some PPI problems" };

		&$_ for grep { $_ } map { ($_->can ('requires'), $_->can ('fix')) } (
			PPIx::Augment::Fix::Magic_Cast::,
			PPIx::Augment::Fix::New_Octal_Numbers::,
			PPIx::Augment::Fix::Ternary_Operator_Colon::,
		);

		$document;
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
