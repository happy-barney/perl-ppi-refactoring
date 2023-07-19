
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

my $TESTING_AUGMENTATION = q (testing_augmentation);

sub testing_augmentation {
	my ($class) = @_;

	proclaim $TESTING_AUGMENTATION => $class;

	require_ok $class;
}

sub assert_augmentation {
	my ($title, %params) = @_;

	my $augmentation = $params{augmentation}
		// deduce ($TESTING_AUGMENTATION)
		// $title
		;

	Test::YAFT::test_frame {
		subtest $title => sub {
			my $document = ppi_document ($params{document});

			assert_ppi q (how PPI should parse document)
				=> document => $document
				=> expect   => $params{expect_ppi}
				if $params{expect_ppi}
				;

			PPIx::Augment::->augment ($document);

			assert_ppi q (how augmentation should modify document)
				=> document => $document
				=> expect   => $params{expect_augmented}
				;

			PPIx::Augment::->augment ($document);

			assert_ppi q (augmentation should be safely applicable twice)
				=> document => $document
				=> expect   => $params{expect_augmented}
				;
		};
	};
}

1;
