
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_constructor @_ };
arrange_document       { q ( {}; { foo }; + { bar }; $a = { baz } ) };

assume_ppi q (should match all instances)
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::Constructor:: => q ({})),
		expect_element (PPI::Structure::Constructor:: => q ({ bar })),
		expect_element (PPI::Structure::Constructor:: => q ({ baz })),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ { sprevious_sibling => sub { it_is_token_operator $_[0] } } ],
	=> expect     => expect_nodeset (
		expect_element (PPI::Structure::Constructor:: => q ({ bar })),
		expect_element (PPI::Structure::Constructor:: => q ({ baz })),
	);

had_no_warnings;
done_testing;

