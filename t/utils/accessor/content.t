
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

local $_ = PPI::Token::->new (q (foo));

assume q (content () should use current element)
	=> got    { content }
	=> expect => q (foo)
	;

assume q (content () should use effective element)
	=> got    { content (PPI::Token::->new (q (bar))) }
	=> expect => q (bar)
	;

had_no_warnings;
done_testing;
