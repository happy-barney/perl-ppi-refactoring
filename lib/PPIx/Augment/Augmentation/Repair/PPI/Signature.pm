
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Repair::PPI::Signature {
	use parent q (PPIx::Augment::Augmentation);

	use PPIx::Augment::Document;
	use PPIx::Augment::Structure::Signature::V520;
	use PPIx::Augment::Utils;

	use namespace::clean;

	sub how_to_augment {
		invoke {
			use PPI::Dumper;
			::diag q (>> ), ref;
			PPI::Dumper::->new ($_)->print for
			my $document = PPI::Document::->new (\ content);

			my $signature = ppix_search $document
				=> where { it_is_structure_list }
				;

			elements_replace current, [
				bless $signature->clone, PPIx::Augment::Structure::Signature::V520::
			];
		}
	}

	sub what_to_augment {
		where { it_is_token_prototype qr (\w) },
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Augmentation::Repair::PPI::Signature::V520

=head1 DESCRIPTION

As of v1.278 L<PPI> treats signatures as L<PPI::Token::Prototype>.

This augmentation recognizes signatures and and replace L<PPI::Token::Prototype>
with an instance of L<PPIx::Augment::Structure::Signature>.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
