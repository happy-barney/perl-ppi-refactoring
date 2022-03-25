
use v5.14;
use warnings;

use require::relative 'test-helper.pl';

it "should compare two values"
	=> got    => [ 'something' ]
	=> expect => [ 'something' ]
	;

ok "should be ok"
	=> got    => 1
	;

had_no_warnings;

done_testing;
