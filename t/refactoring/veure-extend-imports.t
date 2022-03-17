
use require::relative "test-helper-refactoring.pl";

note <<'';
	veure::extend-imports adds missing import parameters to existing
	use statement of module.

plan tests => 7;

testing_refactoring 'veure::extend-imports';

test_ppix_refactoring "it should return undef when given module is not imported yet"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
	=> document         => <<'		DOCUMENT'
		DOCUMENT
	=> expect_status    => undef
	;

test_ppix_refactoring "it should extend existing import with qw//"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar qw/existing/;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw/existing fun1 fun2/;
		EXPECT
	;

test_ppix_refactoring "it should extend existing import with empty qw//"
	=> with             => [qw[ Foo::Bar aaa fun2 ]],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar qw/existing/;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw/existing aaa fun2/;
		EXPECT
	;

test_ppix_refactoring "it should extend existing import qw// following existing indent"
	=> with             => [qw[ Foo::Bar aaa fun2 ]],
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
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
	=> document         => <<'		DOCUMENT'
		use Foo::Bar 'existing';
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		use Foo::Bar qw(existing fun1 fun2);
		EXPECT
	;

had_no_warnings;

done_testing;
