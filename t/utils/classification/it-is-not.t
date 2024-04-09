
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

subtest q (it_is_not { ... }) => sub {
	assume q (it negates 'ppi_include')
		=> got     { it_is_not { ppi_include } }
		=> expect  { expect_ppi_exclude }
		;

	assume q (it negates 'ppi_exclude')
		=> got     { it_is_not { ppi_exclude } }
		=> expect  { expect_ppi_include }
		;

	assume q (it negates 'ppi_exclude_all')
		=> got     { it_is_not { ppi_exclude_all } }
		=> expect  { expect_ppi_include }
		;
};

subtest q (& it_is_not ( ... )) => sub {
	assume q (it negates 'ppi_include')
		=> got     { & it_is_not (ppi_include) }
		=> expect  { expect_ppi_exclude }
		;

	assume q (it negates 'ppi_exclude')
		=> got     { & it_is_not (ppi_exclude) }
		=> expect  { expect_ppi_include }
		;

	assume q (it negates 'ppi_exclude_all')
		=> got     { & it_is_not (ppi_exclude_all) }
		=> expect  { expect_ppi_include }
		;
};

had_no_warnings;
done_testing;
