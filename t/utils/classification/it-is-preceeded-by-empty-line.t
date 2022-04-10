
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

my $preceding_empty_line = augmented_document (<<'DOCUMENT');
foo;

bar;
DOCUMENT

check_ppi "preceding empty line"
	=> document => $preceding_empty_line
	=> where    => where { it_is_preceeded_by_empty_line }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Statement' => "bar;"),
	);

my $with_indent = augmented_document (<<"DOCUMENT");
\tfoo;

\tbar;
DOCUMENT

check_ppi "preceding empty line with indent"
	=> document => $with_indent
	=> where    => where { it_is_preceeded_by_empty_line }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Token::Whitespace' => "\t"),
		expect_element ('PPI::Statement' => "bar;"),
	);

had_no_warnings;

done_testing;
