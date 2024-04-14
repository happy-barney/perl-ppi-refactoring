
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_accessor { child_index @_ };
arrange_document { <<'END_OF_DOCUMENT' };
package Foo { }
END_OF_DOCUMENT

assume_accessor q (it should return index of child in it's parent)
	=> where    => where { it_is_token_word q (Foo) }
	=> expect   => [ 2 ]
	;

assume_accessor q (it should return 'undef' when element doesn't have a parent)
	=> element  => build_semicolon
	=> expect   => [ undef ]
	;

had_no_warnings;
done_testing;

