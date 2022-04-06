
use v5.14;
use warnings;

use require::relative "test-helper-classification.pl";

local *classification = \& it_is;

my $element = PPI::Token::Word::->new ('foo');

it_behaves_like_classification "it should accept element when it implements class"
	=> element => $element
	=> with    => [ PPI::Element:: ]
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject element when it doesn't implement class"
	=> element => $element
	=> with    => [ PPI::Statement:: ]
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should accept element when it implements class and matches content exactly"
	=> element => $element
	=> with    => [ PPI::Token::, 'foo' ]
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should accept element when it implements class and matches content by regex"
	=> element => $element
	=> with    => [ PPI::Token::, qr/o/ ]
	=> expect  => expect_ppi_true
	;

it_behaves_like_classification "it should reject element when it implements class and doesn't match content exactly"
	=> element => $element
	=> with    => [ PPI::Token::, 'foo', 'bar' ]
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should accept element when it implements class and doesn't match content by regex"
	=> element => $element
	=> with    => [ PPI::Token::, 'foo', qr/b/ ]
	=> expect  => expect_ppi_false
	;

it_behaves_like_classification "it should reject element when it doesn't implement class even if content matches"
	=> element => $element
	=> with    => [ PPI::Statement::, 'foo' ]
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

