
use v5.14;
use warnings;

use require::relative "test-helper-refactoring.pl";

note <<'';
	veure::extend-imports adds missing import parameters to existing
	use statement of module.

plan tests => 9;

testing_refactoring 'veure::extend-imports';

test_ppix_refactoring "it should return undef when given module is not imported yet"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		DOCUMENT
	=> expect_status    => undef
	;

test_ppix_refactoring "it should extend existing import with qw//"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar qw/existing/;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw/existing fun1 fun2/;
		EXPECT
	;

test_ppix_refactoring "it should extend existing import with empty qw//"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  aaa fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar qw/existing/;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw/existing aaa fun2/;
		EXPECT
	;

test_ppix_refactoring "it should extend existing import qw// following existing indent"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  aaa fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar qw(
			existing
		);
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw(
			existing
			aaa
			fun2
		);
		EXPECT
	;

test_ppix_refactoring "it should extend existing import with single string value"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar 'existing';
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw(existing fun1 fun2);
		EXPECT
	;

test_ppix_refactoring "it should extend existing import in specified package"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  fun1 fun2 ]], context => 'AAA' ],
	=> document         => <<'		DOCUMENT'
		package AAA;
		use Foo::Bar qw/existing/;
		package BBB;
		use Foo::Bar qw/another/
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		package AAA;
		use Foo::Bar qw/existing fun1 fun2/;
		package BBB;
		use Foo::Bar qw/another/
		EXPECT
	;

test_ppix_refactoring "it should extend last existing import qw//"
	=> with             => [ module => 'Foo::Bar', imports => [qw[  aaa fun2 ]] ],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar qw( existing );
		use Foo::Bar qw( another );
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw( existing );
		use Foo::Bar qw( another aaa fun2 );
		EXPECT
	;

had_no_warnings;

done_testing;
