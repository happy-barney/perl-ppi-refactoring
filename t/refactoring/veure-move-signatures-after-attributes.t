
use v5.14;
use warnings;

use require::relative "test-helper-refactoring.pl";

#plan tests => 8;
testing_refactoring 'veure::move-signatures-after-attributes';

test_ppix_refactoring "it shouldn't refactor when there are no attributes"
	=> document         => <<'DOCUMENT'
sub foo ($foo) {}
DOCUMENT
	=> expect_status    => 0
	=> expect_document  => <<'EXPECT'
sub foo ($foo) {}
EXPECT
	;

test_ppix_refactoring "it shouldn't refactor when there is no signature"
	=> document         => <<'DOCUMENT'
sub foo :ATTR {}
DOCUMENT
	=> expect_status    => 0
	=> expect_document  => <<'EXPECT'
sub foo :ATTR {}
EXPECT
	;

test_ppix_refactoring "it should move signatures after last attribute"
	=> document         => <<'DOCUMENT'
sub base ( $self, $c ) : ChainedParent PathPart('path') {}
DOCUMENT
	=> expect_status    => 1
	=> expect_document  => <<'EXPECT'
sub base : ChainedParent PathPart('path') ( $self, $c ) {}
EXPECT
	;

had_no_warnings;

done_testing;
