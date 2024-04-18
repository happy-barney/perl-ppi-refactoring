
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { &it_is_followed_by_empty_line };
arrange_document       { <<'END_OF_DOCUMENT' };
sub foo;
sub bar;


sub baz;
END_OF_DOCUMENT

assume_ppi q (should match empty lines)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Sub::    => q  (sub bar;),  { line_number => 2 }),
		expect_element (PPI::Token::Structure::  => q  (;),         { line_number => 2 }),
		expect_element (PPI::Token::Whitespace:: => qq (\n),        { line_number => 2 }),
	);

had_no_warnings;
done_testing;

