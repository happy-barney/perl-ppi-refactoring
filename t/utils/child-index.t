
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

plan tests => 4;

my $document = document 'foo + bar;baz';

my ($foo, $bar, $baz) = ppix_find $document, where { it_is_token_word };

it "foo should be at position 0"
	=> got    => child_index ($foo)
	=> expect => 0
	;

it "bar should be at position 4"
	=> got    => child_index ($bar)
	=> expect => 4
	;

local $_ = $baz->parent;
it "statement with baz should be at position 1"
	=> got    => child_index,
	=> expect => 1
	;

had_no_warnings;

done_testing;
