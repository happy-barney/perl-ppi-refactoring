
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_significant @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
{ 1 2; }
END_OF_DOCUMENT

assume_ppi q (should match significant elements)
	=> expect   => expect_nodeset (
		expect_element (PPI::Statement::Compound:: => qq ({ 1 2; })),
		expect_element (PPI::Structure::Block::    => qq ({ 1 2; })),
		expect_element (PPI::Token::Structure::    => q ({)),
		expect_element (PPI::Statement::           => q (1 2;)),
		expect_element (PPI::Token::Number::       => q (1)),
		expect_element (PPI::Token::Number::       => q (2)),
		expect_element (PPI::Token::Structure::    => q (;)),
		expect_element (PPI::Token::Structure::    => q (})),
	);

had_no_warnings;
done_testing;

