
use v5.14;
use warnings;

use require::relative "test-helper-refactoring.pl";

#plan tests => 9;

testing_refactoring 'eliminate-cache-variable';

test_ppix_refactoring "it should return undef there is no cache variable"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		DOCUMENT
	=> expect_status    => undef
	;

test_ppix_refactoring "it should find and eliminate unused cache variable"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		state $false = json_false;
		state $true = json_true;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		state $false = json_false;
		EXPECT
	;

test_ppix_refactoring "it should find and eliminate cache variable and their usage in their scope"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		sub foo {
			$true;
			state $true = json_true;
			return $true;
		}
		$true
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		sub foo {
			$true;
			return json_true;
		}
		$true
		EXPECT
	;

test_ppix_refactoring "it should preserve preceeding empty line yet still consume current line"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		if (my $true = 1) {
			$true;
		}

		state $true  = json_true;
		state $false = json_false;

		$success ? $true : $false;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		if (my $true = 1) {
			$true;
		}

		state $false = json_false;

		$success ? json_true : $false;
		EXPECT
	;

test_ppix_refactoring "use case - it should preserve only one empty line (previously) around declaration"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		if (my $true = 1) {
			$true;
		}

		state $true  = json_true;

		$success ? $true : $false;
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		if (my $true = 1) {
			$true;
		}

		$success ? json_true : $false;
		EXPECT
	;


test_ppix_refactoring "use case - it should eliminated multiple nested cached variables"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		state $true  = json_true;
		my $foo = $true;

		sub foo {
			state $true  = json_true;
			my $foo = $true;
		}
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		my $foo = json_true;

		sub foo {
			my $foo = json_true;
		}
		EXPECT
	;

test_ppix_refactoring "use case - it should eliminated multiple nested cached variables"
	=> with             => [ 'json_true' ]
	=> document         => <<'		DOCUMENT'
		sub foo {
			state $true = json_true;

			return $true;
		}
		DOCUMENT
	=> expect_status    => bool (1)
	=> expect_document  => <<'		EXPECT'
		sub foo {
			return json_true;
		}
		EXPECT
	;
had_no_warnings;

done_testing;
