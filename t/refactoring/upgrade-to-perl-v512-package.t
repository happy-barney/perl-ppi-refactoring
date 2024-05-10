
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Refactoring::Upgrade::To::Perl::V512::Package;

testing_refactoring { PPIx::Refactoring::Upgrade::To::Perl::V512::Package:: };

assume_refactoring q (should upgrade package declaration to package-block)
	=> document        => <<"END_OF_DOCUMENT"
package Foo;
sub foo {
\t1
}
END_OF_DOCUMENT
	=> expect_result   => <<"END_OF_DOCUMENT"
package Foo {
\tsub foo {
\t\t1
\t}
}
END_OF_DOCUMENT
	;

had_no_warnings;
done_testing;
