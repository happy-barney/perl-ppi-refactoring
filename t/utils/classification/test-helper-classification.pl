
use v5.14;
use warnings;

use require::relative "../traversal/test-helper-traversal.pl";

sub classification;

sub it_behaves_like_classification {
	my ($title, %args) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	die "classification not specified, run 'local *classification = sub { }' first"
		unless defined &classification;

	my $element = $args{element};
	my $with    = $args{with} // [];
	my $expect  = $args{expect};

	$expect = test_deep_cmp_ppi_bool ($expect)
		unless $expect->$_isa (Test::Deep::Cmp::);

	subtest $title => sub {
		it "should accept element as its first argument"
			=> got    => classification ($element, @$with)
			=> expect => $expect
			;

		it "should accept current element"
			=> got    => do { local $_ = $element; classification (@$with) }
			=> expect => $expect
			;

		if (eq_deeply 1, $expect) {
			it "should prefer current element passed as "
				=> got    => do { local $_ = $element; classification (\ [ ref $element ]) }
				=> expect => expect_ppi_false
			;
		}
	};
}

1;
