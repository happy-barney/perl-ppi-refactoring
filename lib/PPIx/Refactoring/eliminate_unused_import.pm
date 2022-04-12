
use v5.14;
use warnings;

package PPIx::Refactoring::eliminate_unused_import {
	use parent qw[ PPIx::Refactoring::Base ];

	use PPIx::Augment::Utils;
	use namespace::clean;

	sub _build_imported_symbols {
		my ($context, $document, $module) = @_;

		my %imports;
		ppix_process $document
			=> where { it_is_use_statement { module => $module } }
			=> invoke {
				my @symbols;
				for my $argument (current->arguments) {
					if (it_is_word_list $argument) {
						push @symbols, grep { ! m/^[-:]/ } $argument->literal;
						next;
					}
					die "Unimplemented - unknown argument";
				}

				my $context_namespace = context_namespace;
				$imports{$context_namespace} = \ @symbols;
			};

		return %imports;
	}

	sub _parse_options {
		my ($self, $options) = @_;

		my $options = $self->SUPER::_parse_options (
			$options,
			'module=s',
			'no-implicit-imports',
			'imports=@s',
			'tags=%s',
		);

		return $options;
	}

	sub refactoring {
		my ($context, $document, @options) = @_;

		my $options = __PACKAGE__->_parse_options (\$options);
		my %imports = $PACKAGE__->_build_imported_symbols ($document, $options->{module});

		for my $namespace (keys %imports) {
			say "==> process namespace $namespace";
			#my %symbols = map +($_ => 1), $module, @{ $imports{$namespace} };
			my %used;
			ppix_process $document
				=> where { it_is_token_word }
				=> where { $namespace eq context_namespace }
				=> where { exists $symbols{$_} }
				=> where { its_parent { is_not it_is_use_statement } }
				=> invoke {
					say "found word $_ (${\ parent })" if exists $symbols{$_};
					$used{$_} = delete $symbols{$_};
				};

			next unless %symbols; # there is no unused symbol

			my $namespace_used = delete $symbols{$namespace};
			say "unused symbols: ", sort keys %symbols;
		}

		
		return;

		return 1;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Refactoring - Basic framework for automated refactorings

=head1 DESCRIPTION

Fix some bugs and improve structre of PPI documents

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

Test::YAFT distribution is distributed under Artistic Licence 2.0.

=cut
