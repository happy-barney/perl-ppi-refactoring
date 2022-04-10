
use v5.14;
use warnings;

package PPIx::Augment {
	use PPI;
	use Safe::Isa;

	require PPIx::Augment::Document;

	require PPIx::Augment::Augmentation::Context::Package;

	require PPIx::Augment::Fix::Magic_Cast;
	require PPIx::Augment::Fix::New_Octal_Numbers;
	require PPIx::Augment::Fix::Newline_Spaces;
	require PPIx::Augment::Fix::Ternary_Operator_Colon;

	sub new {
		my ($class, @args) = @_;

		return $class->augment (@args);
	}

	sub augment {
		my ($self, $source) = @_;

		$source = PPI::Document::->new ($source)
			unless $source->$_isa (PPI::Document::);

		bless $source, PPIx::Augment::Document::;

		for my $augmentation ($self->augmentations) {
			$augmentation->requires ($source) if $augmentation->can ('requires');
			$augmentation->augment ($source);
		}

		$source;
	}

	sub augmentations {
		+(
			PPIx::Augment::Fix::Magic_Cast::,
			PPIx::Augment::Fix::New_Octal_Numbers::,
			PPIx::Augment::Fix::Newline_Spaces::,
			PPIx::Augment::Fix::Ternary_Operator_Colon::,

			PPIx::Augment::Augmentation::Context::Package::,
		)
	}

	no warnings 'redefine';
	# handle multiline prototypes - usually signatures
	sub PPI::Token::Prototype::__TOKENIZER__on_char {
		my $class = shift;
		my $t     = shift;

		# Suck in until we find the closing paren (or the end of line)
		pos $t->{line} = $t->{line_cursor};
		die "regex should always match" if $t->{line} !~ m/\G([^\)]*\)?)/gc;
		$t->{token}->{content} .= $1;
		$t->{line_cursor} += length $1;

		# Shortcut if end of line
		return 0 unless $1 =~ /\)$/;


		# Found the closing paren
		my $rv = $t->_finalize_token->__TOKENIZER__on_char( $t );
		$rv;
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
