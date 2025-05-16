
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

ok q (should pass for ppi_include ())
	=> got => eq_deeply (ppi_include, expect_ppi_include)
	;

nok q (should fail for ppi_exclude ())
	=> got => eq_deeply (ppi_exclude, expect_ppi_include)
	;

nok q (should fail for ppi_exclude_all ())
	=> got => eq_deeply (ppi_exclude_all, expect_ppi_include)
	;

had_no_warnings;
done_testing;
