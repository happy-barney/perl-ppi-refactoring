
use v5.14;
use warnings;

use require::relative "test-helper-refactoring.pl";

use PPIx::Refactoring::replace::token_word;

testing_refactoring 'replace::token-word';

test_ppix_refactoring "it should not insert include when token was not replaced"
	=> with             => [qw[ --word Baz --with json_true --import Utils]],
	=> filename         => 'Foo/Bar.pm'
	=> document         => <<'DOCUMENT'
package Foo::Bar;
use Veure::Module;

my $true = JSON::true;
DOCUMENT
	=> expect_status    => 0
	=> expect_document  => <<'EXPECT'
package Foo::Bar;
use Veure::Module;

my $true = JSON::true;
EXPECT
	;

test_ppix_refactoring "it should replace token"
	=> with             => [qw[ --word JSON::true --with json_true --exclude /Exclude.pm ]],
	=> filename         => 'Foo/Bar.pm'
	=> document         => <<'DOCUMENT'
package Foo::Bar;
use Veure::Module;

my $true = JSON::true;
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
package Foo::Bar;
use Veure::Module;

my $true = json_true;
EXPECT
	;

test_ppix_refactoring "it should not replace token when file name is excluded"
	=> with             => [qw[ --word JSON::true --with json_true --exclude /Exclude.pm ]],
	=> filename         => 'lib/Exclude.pm'
	=> document         => <<'DOCUMENT'
package Foo::Bar;
use Veure::Module;

my $true = JSON::true;
DOCUMENT
	=> expect_status    => 0
	=> expect_document  => <<'EXPECT'
package Foo::Bar;
use Veure::Module;

my $true = JSON::true;
EXPECT
	;

test_ppix_refactoring "it should replace token and import symbol"
	=> with             => [qw[ --word JSON::true --with json_true --import Utils ]],
	=> filename         => 'Foo/Bar.pm'
	=> document         => <<'DOCUMENT'
package Foo::Bar;
use Veure::Module;

my $true = JSON::true;
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
package Foo::Bar;
use Veure::Module;
use Utils qw(json_true);

my $true = json_true;
EXPECT
	;

had_no_warnings;

done_testing;
