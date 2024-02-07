
use v5.14;
use warnings;

use require::relative q (test-helper-traversal.pl);

subtest q (expect_ppi_true()) => sub {
	my $expect = expect_ppi_true;

	ok q (should pass for ppi_true())
		=> got    => eq_deeply (ppi_true, $expect)
		;

	nok q (should fail for ppi_false())
		=> got    => eq_deeply (ppi_false, $expect)
		;

	nok q (should fail for ppi_false_dont_descent())
		=> got    => eq_deeply (ppi_false_dont_descent, $expect)
		;
};

subtest q (expect_ppi_false()) => sub {
	my $expect = expect_ppi_false;

	nok q (should fail for ppi_true())
		=> got    => eq_deeply (ppi_true, $expect)
		;

	ok  q (should pass for ppi_false())
		=> got    => eq_deeply (ppi_false, $expect)
		;

	nok q (should fail for ppi_false_dont_descent())
		=> got    => eq_deeply (ppi_false_dont_descent, $expect)
		;
};

subtest q (expect_ppi_false_do_not_descend()) => sub {
	my $expect = expect_ppi_false_do_not_descend;

	nok q (should fail for ppi_true())
		=> got    => eq_deeply (ppi_true, $expect)
		;

	nok q (should fail for ppi_false())
		=> got    => eq_deeply (ppi_false, $expect)
		;

	ok  q (should pass for ppi_false_dont_descent())
		=> got    => eq_deeply (ppi_false_dont_descent, $expect)
		;
};

had_no_warnings;

done_testing;
