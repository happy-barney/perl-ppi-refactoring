
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

use PPIx::Augment::Internals qw (push_unique_string);

act {
	my ($list, $values) = @_;
	push_unique_string @$list, @$values;
	$list
}
	q (list),
	q (values),
	;

assume q (push_unique_string () should push non-existing string)
	=> with_list   => [ ],
	=> with_values => [ q (foo) ],
	=> expect      => [ q (foo) ],
	;

assume q (push_unique_string () shouldn't push existing string)
	=> with_list   => [ q (foo), q (bar) ],
	=> with_values => [ q (foo) ],
	=> expect      => [ q (foo), q (bar) ],
	;

assume q (push_unique_string () shouldn't push non-existing string multiple times)
	=> with_list   => [ q (foo), q (bar) ],
	=> with_values => [ q (xyz), q (xyz) ],
	=> expect      => [ q (foo), q (bar), q (xyz) ],
	;

assume q (push_unique_string () shouldn't fail when there are no values)
	=> with_list   => [ q (foo), q (bar) ],
	=> with_values => [ ],
	=> expect      => [ q (foo), q (bar) ],
	;

had_no_warnings;
done_testing;
