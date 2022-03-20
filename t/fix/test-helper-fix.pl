
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

my $TESTING_FIX;

sub testing_ppi_fix {
	my ($class) = @_;

	$TESTING_FIX = $class;

	require_ok ($class);
}

sub behaves_like_ppi_fix {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	subtest $title => sub {
		my $fix = $params{fix} // $TESTING_FIX // $title;
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

sub ppix_augment_should_execute_ppi_fix {
	my ($fix) = @_;
	$fix //= $TESTING_FIX;

	return fail "ppix_augment_should_execute_fix requires Fix class"
		unless $fix ;

	my $called;

	my $guard = Sub::Override->new (
		"${fix}::augment" => sub { $called = 1 },
	);

	augmented_document ('');

	$called
		? pass "PPIx::Augment->augment calls $fix"
		: fail "PPIx::Augment->augment doesn't call $fix"
		;
}


1;

