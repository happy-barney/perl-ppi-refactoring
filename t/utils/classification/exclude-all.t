
use v5.14;
use warnings;

use require::relative q (../../test-helper.pl);

use PPIx::Augment::Utils;

it q (should preserve 'ppi_include')
	=> got    { exclude_all { ppi_include } }
	=> expect => ppi_include
	;

it q (should preserve 'ppi_exclude_all')
	=> got    { exclude_all { ppi_exclude_all } }
	=> expect => ppi_exclude_all
	;

it q (should transform 'ppi_exclude' into 'ppi_exclude_all')
	=> got    { exclude_all { ppi_exclude } }
	=> expect => ppi_exclude_all
	;

it q (should preserve 'ppix_include')
	=> got    { exclude_all { ppix_include } }
	=> expect => ppi_include
	;

it q (should preserve 'ppix_exclude_all')
	=> got    { exclude_all { ppix_exclude_all } }
	=> expect => ppi_exclude_all
	;

it q (should transform 'ppix_exclude' into 'ppi_exclude_all')
	=> got    { exclude_all { ppix_exclude } }
	=> expect => ppi_exclude_all
	;

had_no_warnings;
done_testing;
