
use v5.14;
use warnings;

package PPIx::Refactoring::replace::token_word {
	use parent qw[ PPIx::Refactoring::Base ];
	use PPIx::Augment::Utils;
	use namespace::clean;
	use Carp::Always;

	sub refactoring {
		my ($context, $document, @options) = @_;

		my %options = __PACKAGE__->_parse_options (
			\@options,
			'word=s',
			'with|replace-with=s',
			'import=s',
		);

		return 0
			if __PACKAGE__->_file_is_excluded ($document, $options{exclude});

		my %import;
		return ppix_transform $document
			=> where { it_is_token_word $options{word} }
			=> invoke {
				current->set_content ($options{with});

				return unless $options{import};

				$import{context_namespace()} //= do {
					$context->refactor ('veure::ensure-import' => (
						module  => $options{import},
						context => context_namespace,
						imports => [ $options{with} ],
					));
				};
			};

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
