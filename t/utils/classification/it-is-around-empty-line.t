
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

plan tests => 4;

check_ppi "should find all statements preceed by empty line"
	=> where    => where { it_is_statement && it_is_preceeded_by_empty_line }
	=> document => <<'		DOCUMENT'
		$foo;

		$bar;

		$baz;
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement', '$bar;'),
		expect_element ('PPI::Statement', '$baz;'),
	);

check_ppi "should find all statements followed by empty line"
	=> where    => where { it_is_statement && it_is_followed_by_empty_line }
	=> document => <<'		DOCUMENT'
		$foo;

		$bar;

		$baz;
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement', '$foo;'),
		expect_element ('PPI::Statement', '$bar;'),
	);

check_ppi "should find all statements surrounded by empty line"
	=> where    => where { it_is_statement && it_is_followed_by_empty_line && it_is_preceeded_by_empty_line }
	=> document => <<'		DOCUMENT'
		$foo;

		$bar;

		$baz;
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement', '$bar;'),
	);

had_no_warnings;

done_testing;
