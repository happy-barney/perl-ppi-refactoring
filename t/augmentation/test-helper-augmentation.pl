
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

my $TESTING_AUGMENTATION;

sub testing_augmentation {
	my ($class) = @_;

	$TESTING_AUGMENTATION = $class;

	require_ok $class;
}

sub behaves_like_augmentation {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $augmentation = $params{augmentation} // $TESTING_AUGMENTATION // $title;
	subtest $title => sub {
		my $document = document ($params{document});

		check_ppi "how PPI should parse document"
			=> document => $document
			=> expect   => $params{expect_ppi}
			if $params{expect_ppi};

		$augmentation->requires ($document);
		$augmentation->augment ($document);

		check_ppi "how augmentation should modify document"
			=> document => $document
			=> expect   => $params{expect_augmented}
			;

		$augmentation->requires ($document);
		$augmentation->augment ($document);

		check_ppi "augmentation should be safely applicable twice"
			=> document => $document
			=> expect   => $params{expect_augmented}
			;
	};
}

1;
