
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Refactoring::Declare::Perl::Version;

testing_refactoring { PPIx::Refactoring::Declare::Perl::Version->new (version => v5.14) };

sub lines { join qq (\n), @_ }

assume_refactoring q (should insert 'use VERSION' as first significant element of source document)
	=> document       => lines (
		q (#!perl),
		q (),
		q (package Foo;),
	)
	=> expect_result  => lines (
		q (#!perl),
		q (),
		q (use v5.14;),
		q (),
		q (package Foo;),
	)
	;

assume_refactoring q (should insert 'use VERSION' before pragma omitting empty line)
	=> document       => lines (
		q (#!perl),
		q (),
		q (use strict;),
	)
	=> expect_result  => lines (
		q (#!perl),
		q (),
		q (use v5.14;),
		q (use strict;),
	)
	;

assume_refactoring q (should update existing 'use VERSION' when statement already exists with lower version)
	=> document       => lines (
		q (#!perl),
		q (),
		q (use v5.12;),
		q (use strict;),
	)
	=> expect_result  => lines (
		q (#!perl),
		q (),
		q (use v5.14;),
		q (use strict;),
	)
	;

assume_refactoring q (shouldn't update existing 'use VERSION' when statement already exists with higher version)
	=> document       => lines (
		q (#!perl),
		q (),
		q (use v5.16;),
		q (use strict;),
	)
	=> expect_result  => lines (
		q (#!perl),
		q (),
		q (use v5.16;),
		q (use strict;),
	)
	;

had_no_warnings;
done_testing;
