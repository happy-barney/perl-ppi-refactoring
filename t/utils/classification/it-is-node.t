
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { & it_is_node };
arrange_document       { q (package Foo { sub Bar { } }) };

assume_ppi q (should match any instance of PPI::Node::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Package:: => q (package Foo { sub Bar { } })),
		expect_element (PPI::Structure::Block::   => q ({ sub Bar { } })),
		expect_element (PPI::Statement::Sub::     => q (sub Bar { })),
		expect_element (PPI::Structure::Block::   => q ({ })),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ sub { it_is_statement } ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Package:: => q (package Foo { sub Bar { } })),
		expect_element (PPI::Statement::Sub::     => q (sub Bar { })),
	);

had_no_warnings;
done_testing;

