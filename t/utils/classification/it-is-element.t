
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_element @_ };

assume_classification q (it should match e.g. PPI::Token::Word::)
	=> element        => PPI::Token::Word::->new (q (foo))
	=> expect         => expect_ppi_include
	;

assume_classification q (it should match e.g. PPI::Statement::Package::)
	=> element        => PPI::Statement::Package::->new
	=> expect         => expect_ppi_include
	;

assume_classification q (it should apply conditions (positive))
	=> element        => PPI::Token::Word::->new (q (foo))
	=> conditions     => [ q (foo) ]
	=> expect         => expect_ppi_include
	;

assume_classification q (it should apply conditions (negative))
	=> element        => PPI::Token::Word::->new (q (foo))
	=> conditions     => [ q (bar) ]
	=> expect         => expect_ppi_exclude
	;

had_no_warnings;
done_testing;
