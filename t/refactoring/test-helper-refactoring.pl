
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

use Test::Differences qw[];

use PPIx::Refactoring;

my $TESTING_REFACTORING;

sub testing_refactoring {
	if (@_) {
		$TESTING_REFACTORING = shift;

		return Test::More::ok
			eval { PPIx::Refactoring->find_refactoring ($TESTING_REFACTORING) } ,
			"should be valid refactoring: $TESTING_REFACTORING"
			;
	}

	$TESTING_REFACTORING;
}

sub test_ppix_refactoring {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $refactoring = $params{refactoring} // testing_refactoring;
	my $document = augmented_document ($params{document});

	$document->{filename} //= $params{filename} // 'inline-document';

	my ($ok, $diag) = (1, undef);

	unless ($refactoring) {
		fail $title;
		diag "Refactoring not specified";
		return;
	}

	unless (eval { PPIx::Refactoring->find_refactoring ($refactoring) }) {
		fail $title;
		diag "Unknown refactoring $refactoring";
		return;
	}

	my $status;
	my $lives_ok = eval {
		$status = PPIx::Refactoring->new ($document)->apply ($refactoring, @{ $params{with} // [] });
		1;
	};
	my $error  = $@;

	unless ($lives_ok) {
		if (exists $params{throws}) {
			return it $title
				=> got    => $error
				=> expect => $params{throws}
				;
		} else {
			fail $title;
			diag "Refactoring died with error:\n$@";
			return;
		}
	}

	if (exists $params{throws}) {
		fail $title;
		diag "Refactoring expected to die but lives";
		return;
	}

	if (exists $params{expect_status}) {
		my ($ok, $stack) = Test::Deep::cmp_details ($status, $params{expect_status});

		unless ($ok) {
			fail $title;
			diag Test::Deep::deep_diag ($stack);
		}

		return pass $title
			unless exists $params{expect_document};
	}

	my $expect = $params{expect_document};

	if (ref $expect) {
		return check_ppi $title
			=> document => $document
			=> expect   => $expect
			;
	}

	Test::Differences::eq_or_diff ($document->content, $expect, $title);
}

1;

