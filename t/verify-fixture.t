
use v5.14;
use warnings;

use Test::Load::Helper;

it q (should build even non-existing fixture path)
	=> got    => fixture_path (q (foo), q (bar), q (baz))
	=> expect =>
		& expect_instance_of (Path::Tiny::)
		& expect_methods (stringify => expect_re (qr (t/fixture/foo/bar/baz$)))
	;

it q (should build read existing fixture)
	=> got    => fixture (q (simple-document.pl))
	=> expect => qq (1;\n)
	;

had_no_warnings;

done_testing;

