
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

subtest q (standard usage - exclude_all { }) => sub {
	assume q (it preserves 'ppi_include')
		=> got    { exclude_all { ppi_include } }
		=> expect { expect_ppi_include }
		;

	assume q (it preserves 'ppi_exclude_all')
		=> got    { exclude_all { ppi_exclude_all } }
		=> expect { expect_ppi_exclude_all }
		;

	assume q (it transforms 'ppi_exclude' into 'ppi_exclude_all')
		=> got    { exclude_all { ppi_exclude } }
		=> expect { expect_ppi_exclude_all }
		;
};

subtest q (bypassing prototype - &exclude_all ( )) => sub {
	assume q (it preserves 'ppi_include')
		=> got    { exclude_all { ppi_include } }
		=> expect { expect_ppi_include }
		;

	assume q (it preserves 'ppi_exclude_all')
		=> got    { exclude_all { ppi_exclude_all } }
		=> expect { expect_ppi_exclude_all }
		;

	assume q (it transforms 'ppi_exclude' into 'ppi_exclude_all')
		=> got    { exclude_all { ppi_exclude } }
		=> expect { expect_ppi_exclude_all }
		;
};

had_no_warnings;
done_testing;
