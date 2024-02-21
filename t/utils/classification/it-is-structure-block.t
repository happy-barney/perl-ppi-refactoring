
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_block @_ };
arrange_document       { q ( package Foo { sub Bar { false } } ) };

assume_ppi q (should match all instances)
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::Block:: => q ({ sub Bar { false } })),
		expect_element (PPI::Structure::Block:: => q ({ false })),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ qr (\p{Lu})x ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::Block:: => q ({ sub Bar { false } })),
	);

had_no_warnings;
done_testing;

