
use v5.14;
use warnings;

use require::relative "./test-helper.pl";

it "should build even non-existing fixture path"
	=> got    => fixture_path ('foo', 'bar', 'baz')
	=> expect => all (
		obj_isa ('Path::Tiny'),
		methods (stringify => re (qr:t/fixture/foo/bar/baz$:))
	);

it "should build read existing fixture"
	=> got    => fixture ('simple-document.pl')
	=> expect => "1;\n",
	;

had_no_warnings;

done_testing;

