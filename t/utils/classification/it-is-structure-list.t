
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_list @_ };
arrange_document       { q ( Foo ( Bar ( () ) ) ) };

assume_ppi q (should match all instances)
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::List:: => q (( Bar ( () ) ))),
		expect_element (PPI::Structure::List:: => q (( () ))),
		expect_element (PPI::Structure::List:: => q (())),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ qr (\p{Lu})x ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::List:: => q (( Bar ( () ) ))),
	);

had_no_warnings;
done_testing;

