
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_newline @_ };

assume_classification q (should accept element containing newline character)
	=> element  => PPI::Token::Whitespace::->new (qq (\n))
	=> expect   => expect_ppi_include
	;

assume_classification q (should reject element which doesn't contain newline character)
	=> element  => PPI::Token::Whitespace::->new (q ( ))
	=> expect   => expect_ppi_exclude
	;

assume_classification q (should reject element which contain also character which isn't newline)
	=> element  => PPI::Token::Whitespace::->new (q (\n ))
	=> expect   => expect_ppi_exclude
	;

had_no_warnings;
done_testing;

