
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_attribute @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
my $foo :attr(1);
sub foo :lvalue prototype($);
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Token::Attribute)
	=> expect   => expect_nodeset (
		expect_element (PPI::Token::Attribute:: => q (lvalue)),
		expect_element (PPI::Token::Attribute:: => q (prototype($))),
	);

had_no_warnings;
done_testing;

