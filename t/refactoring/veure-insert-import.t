
use v5.14;
use warnings;

use require::relative "test-helper-refactoring.pl";

note <<'';
	veure::extend-imports adds missing import parameters to existing
	use statement of module.

plan tests => 8;
testing_refactoring 'veure::insert-import';

test_ppix_refactoring "it should insert after last use statement"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'DOCUMENT'
use Bar;
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
use Bar;
use Foo::Bar qw(fun1 fun2);
EXPECT
	;

test_ppix_refactoring "it should insert before Veure::Moo"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'DOCUMENT'
use Bar;
use Veure::Moo;
use Baz;
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
use Bar;
use Foo::Bar qw(fun1 fun2);
use Veure::Moo;
use Baz;
EXPECT
	;

test_ppix_refactoring "it should copy indentation (middle)"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Bar;
		use Veure::Moo;
		use Baz;
		DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'		EXPECT'
		use Bar;
		use Foo::Bar qw(fun1 fun2);
		use Veure::Moo;
		use Baz;
		EXPECT
	;

test_ppix_refactoring "it should copy indentation (end)"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Bar;
		use Baz;

		DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'		EXPECT'
		use Bar;
		use Baz;
		use Foo::Bar qw(fun1 fun2);

		EXPECT
	;

test_ppix_refactoring "it should insert import into specified package (when multiple specified)"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]], context => 'Baz' ],
	=> document         => <<'		DOCUMENT'
		package Foo;
		use Bar;
		use Foo::Bar;
		package Baz;
		use Baz;
		DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'		EXPECT'
		package Foo;
		use Bar;
		use Foo::Bar;
		package Baz;
		use Baz;
		use Foo::Bar qw(fun1 fun2);
		EXPECT
	;

test_ppix_refactoring "it should insert import into specified package (package block)"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]], context => 'Foo' ],
	=> document         => <<'		DOCUMENT'
		package Foo;
		use Bar;
		package Baz {
			use Baz;
		}
		DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'		EXPECT'
		package Foo;
		use Bar;
		use Foo::Bar qw(fun1 fun2);
		package Baz {
			use Baz;
		}
		EXPECT
	;

had_no_warnings;

done_testing;
