
use v5.14;
use warnings;

use require::relative "test-helper.pl";

sub ppix_augmentation;

sub testing_ppix_augmentation {
	my ($class) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	require_ok ($class);

	sub { $class };
}

sub behaves_like_ppix_augmentation {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	subtest $title => sub {
		my $fix = $params{fix};
		$fix //= ppix_augmentation if defined &ppix_augmentation;
		$fix //= $title;

		my $document = document ($params{document});

		plan tests => $params{expect_ppi} ? 3 : 2;

		check_ppi "how PPI should parse document"
			=> document => $document
			=> expect   => $params{expect_ppi}
			if $params{expect_ppi};

		_ppix_augment_apply $document, $fix, qw[ requires augment ];

		check_ppi "how fix should modify document"
			=> document => $document
			=> expect   => $params{expect_fixed}
			;

		_ppix_augment_apply $document, $fix, qw[ requires augment ];

		check_ppi "fix should be safely applicable twice"
			=> document => $document
			=> expect   => $params{expect_fixed}
			;
	};
}

sub ppix_augment_should_execute_ppix_augmentation {
	my ($class) = @_;
	$class = ppix_augmentation
		if ! $class && defined &ppix_augmentation;

	return fail "ppix_augment_should_execute_ppix_augmentation requires Augmentation class"
		unless $class;

	my $called;

	my $guard = Sub::Override->new (
		"${class}::augment" => sub { $called = 1 },
	);

	augmented_document ('');

	$called
		? pass "PPIx::Augment->augment calls ${class}"
		: fail "PPIx::Augment->augment doesn't call ${class}"
		;
}

1;

