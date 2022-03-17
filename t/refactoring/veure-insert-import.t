
use require::relative "test-helper-refactoring.pl";

note <<'';
	veure::extend-imports adds missing import parameters to existing
	use statement of module.

plan tests => 5;

use PPIx::Refactoring::veure::insert_import;

testing_refactoring 'veure::insert-import';

test_ppix_refactoring "it should insert after last use statement"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
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
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
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

test_ppix_refactoring "it should copy indentation"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
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

had_no_warnings;

done_testing;
