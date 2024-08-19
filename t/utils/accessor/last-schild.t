
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { last_schild @_ };
arrange_document { fixture q (accessor-for-children.pl) };

# see also: t/verify-fixture-structure-accessor-for-children.t

assume_accessor q (last significant child of document should be statement with number 3)
	=> expect   => expect_nodeset (
		expect_statement (q (3;)),
	);

assume_accessor q (last significant child of list should be token '2')
	=> where    => where { it_is_statement_expression }
	=> expect   => expect_nodeset (
		expect_token_number (q (2)),
	);

assume_accessor q (last significant child of 'PPI::Element' shouldn't exist)
	=> where    => where { it_is_token_number q (2) }
	=> expect   => expect_nodeset (
		expect_no_element
	);

had_no_warnings;
done_testing;

