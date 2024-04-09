
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

subtest q (expect_ppi_include ()) => sub {
	ok q (should pass for ppi_include ())
		=> got    => eq_deeply (ppi_include, expect_ppi_include)
		;

	nok q (should fail for ppi_exclude ())
		=> got    => eq_deeply (ppi_exclude, expect_ppi_include)
		;

	nok q (should fail for ppi_exclude_all ())
		=> got    => eq_deeply (ppi_exclude_all, expect_ppi_include)
		;
};

subtest q (expect_ppi_exclude ()) => sub {
	nok q (should fail for ppi_include ())
		=> got    => eq_deeply (ppi_include, expect_ppi_exclude)
		;

	ok  q (should pass for ppi_exclude ())
		=> got    => eq_deeply (ppi_exclude, expect_ppi_exclude)
		;

	nok q (should fail for ppi_exclude_all ())
		=> got    => eq_deeply (ppi_exclude_all, expect_ppi_exclude)
		;
};

subtest q (expect_ppi_exclude_all ()) => sub {
	nok q (should fail for ppi_include ())
		=> got    => eq_deeply (ppi_include, expect_ppi_exclude_all)
		;

	nok q (should fail for ppi_exclude ())
		=> got    => eq_deeply (ppi_exclude, expect_ppi_exclude_all)
		;

	ok  q (should pass for ppi_exclude_all ())
		=> got    => eq_deeply (ppi_exclude_all, expect_ppi_exclude_all)
		;
};

had_no_warnings;
done_testing;
