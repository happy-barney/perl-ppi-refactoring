
use v5.14;
use warnings;

use require::relative '../test-helper.pl';

it "ppix_find() without arguments should return empty list"
	=> got    => [ ppix_find ]
	=> expect => [ ]
	;

it "ppix_find() without where clause should return empty list"
	=> got    => [ ppix_find document ('1;foo;2;bar') ]
	=> expect => [ ]
	;

it "ppix_find() should evaluate where clause"
	=> got    => [ ppix_find document ('1;foo;2;bar')
		=> where { $_->isa ('PPI::Token::Number') }
	]
	=> expect => [
		expect_element ('PPI::Token::Number', 1),
		expect_element ('PPI::Token::Number', 2),
	];

it "ppix_find() should evaluate all conditions"
	=> got    => [ ppix_find document ('1;foo;2;bar')
		=> where { $_->isa ('PPI::Token::Number') }
		=> sub { $_[1]->content eq '2' }
	]
	=> expect => [
		expect_element ('PPI::Token::Number', 2),
	];

had_no_warnings;

done_testing;

