
use require::relative "test-helper-refactoring.pl";

note <<'';
	veure::extend-imports adds missing import parameters to existing
	use statement of module.

plan tests => 5;

use PPIx::Refactoring::veure::json_constants;

testing_refactoring 'veure::json-constants';

test_ppix_refactoring "it should replace JSON boolean methods with Veure::Util::Data constants (and insert related imports)"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
	=> filename         => 'Foo/Bar.pm'
	=> document         => <<'DOCUMENT'
use Veure::Module;

my $true = JSON->true;
my $false = JSON->false;
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
use Veure::Module;
use Veure::Util::Data qw(json_false json_true);

my $true = json_true;
my $false = json_false;
EXPECT
	;

test_ppix_refactoring "it should ignore Veure::Util::Data module"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
	=> filename         => 'foo/Veure/Util/Data.pm'
	=> document         => <<'DOCUMENT'
use Veure::Module;

my $true = JSON->true;
my $false = JSON->false;
DOCUMENT
	=> expect_status    => 0
	=> expect_document  => <<'EXPECT'
use Veure::Module;

my $true = JSON->true;
my $false = JSON->false;
EXPECT
	;

test_ppix_refactoring "it should import only actually used function"
	=> with             => [qw[ Foo::Bar fun1 fun2 ]],
	=> filename         => 'Foo/Bar.pm'
	=> document         => <<'DOCUMENT'
use Veure::Module;

my $true = JSON->true;
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
use Veure::Module;
use Veure::Util::Data qw(json_true);

my $true = json_true;
EXPECT
	;

had_no_warnings;

done_testing;
