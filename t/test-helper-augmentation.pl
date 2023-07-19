
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

my $AUGMENTATION_SINGLETON = q (testing-ppix-augmentation);

sub testing_ppix_augmentation (&) {
	my ($code) = @_;
	my $class = $code->();

	Module::Load::load ($class);

	proclaim $AUGMENTATION_SINGLETON => $class;
}

sub assume_ppix_augmentation {
	my ($title, %params) = @_;

	Test::YAFT::test_frame {
		subtest $title => sub {
			my $augmentation = $params{augmentation};
			$augmentation //= deduce ($AUGMENTATION_SINGLETON)
				if try_deduce ($AUGMENTATION_SINGLETON)
				;
			$augmentation //= $title;

			my $document = ppi_document ($params{document});

			plan tests => $params{expect_parsed} ? 3 : 2;

			assume_ppi q (PPI should parse document)
				=> document => $document
				=> expect   => $params{expect_parsed}
				if $params{expect_parsed}
				;

			PPIx::Augment->_apply_augmentations ($document, $augmentation);

			assume_ppi q (augmentation should modify document)
				=> document => $document
				=> expect   => $params{expect_augmented}
				;

			PPIx::Augment->_apply_augmentations ($document, $augmentation);

			assume_ppi q (augmentation should be safely applicable twice)
				=> document => $document
				=> expect   => $params{expect_augmented}
			;
		}
	}
}

sub assume_ppix_augment_knows_augmentation {
	my ($class) = @_;
	$class //= deduce ($AUGMENTATION_SINGLETON)
		if try_deduce ($AUGMENTATION_SINGLETON)
		;

	Test::YAFT::test_frame {
		return fail q (assume_ppix_augment_executes_augmentation requires Augmentation class)
			unless $class;

		it qq (PPIx::Augment should know about $class)
			=> got    { [ PPIx::Augment::->augmentations ] }
			=> expect => expect_superbag ($class)
			;
	};
}

1;

