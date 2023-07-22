
use v5.14;
use warnings;

package PPIx::Augment::Statement::Use {
	use parent qw[ PPI::Statement::Include ];
	use PPIx::Augment::Utils;
	use namespace::clean;

	sub _imported_symbols {
		my ($self) = @_;

		return if $self->{_imported_symbols};

		my @symbols;

		for ($self->arguments) {
			when (it_is_token_quote | it_is_token_quotelike_words) {
				push @symbols, $argument->literal;
			}

			die "Unimplemented: unrecognized argument ${\ ref $_ } => $_";
		}

		$self->{_has_symbols} = scalar @symbols;
		$self->{_imported_symbols} = \ @symbols;

		return;
	}

	sub imports_symbols {
		my ($self) = @_;

		$self->_imported_symbols;

		return $self->{_has_symbols};
	}

	sub imported_symbols {
		my ($self) = @_;

		$self->_imported_symbols;

		return @{ $self->{_imported_symbols} };
	}

	sub remove_imported_symbols {
		my ($self, @remove) = @_;

		$self->_imported_symbols;

		return unless @remove;
		return unless $self->{_has_symbols};

		my %remove = map { $_ => 1 } @remove;
		@{ $self->_imported_symbols} = grep exists $remove{$_}, @remove;
		$self->{_has_symbols} = scalar @symbols;

		return;
	}

	sub save_arguments {
		my ($self, $class, %options) = @_;

		$_->remove for $self->arguments;

		unless ($self->{-has_symbol}) {
			$self->add_element (create_token_word_list
		}

		return unless $self->{_

		my $new_argument;

		element_replace ($

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Statement::Use - Wrap use statement

=head1 INHERITANCE

	PPIx::Augment::Statement::Use
		isa PPI::Statement::Include
			isa PPI::Statement
			isa PPI::Node
				isa PPI::Element

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
