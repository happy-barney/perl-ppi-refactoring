
use v5.14;
use warnings;

package PPIx::Refactoring::veure::json_condition {
	use PPIx::Augment::Utils;
	use namespace::clean;
	use Carp::Always;

	sub exclude_files {
		'/Veure/Util/Data.pm'
	}

	sub exclude_files_regexp {
		state $regex = do { join '|', map qr/(?:\Q$_\E)/, exclude_files };
	}

	sub refactoring {
		my ($context, $document, $method) = @_;

		return 0
			if $document->filename =~ exclude_files_regexp;

	return unless ppix_process $document
		=> where {
			return ppi_false unless it_is_operator '?';

			local $_= snext_sibling;
			return ppi_false unless it_is_token_word qr/^json_(?:true|false)$/;

			local $_= snext_sibling;
			return ppi_false unless it_is_operator ':';

			local $_= snext_sibling;
			return ppi_false unless it_is_token_word qr/^json_(?:true|false)$/;
		}
		=> invoke {
			say '-' x 16;
			say parent;
		}
		;

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
