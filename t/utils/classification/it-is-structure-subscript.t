
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_structure_subscript @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
$foo[0];
$foo->[1];
$foo{2};
$foo->{3};
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Token::Subscript)
	=> expect   => expect_nodeset (
		expect_element (PPI::Structure::Subscript:: => q ([0])),
		expect_element (PPI::Structure::Subscript:: => q ([1])),
		expect_element (PPI::Structure::Subscript:: => q ({2})),
		expect_element (PPI::Structure::Subscript:: => q ({3})),
	);

assume_ppi q (should accept additional arguments)
	=> conditions => [ qr ([12]) ]
	=> expect   => expect_nodeset (
		expect_element (PPI::Structure::Subscript:: => q ([1])),
		expect_element (PPI::Structure::Subscript:: => q ({2})),
	);

had_no_warnings;
done_testing;

