
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

use PPIx::Augment::Internals qw (flatten_array);

act { [ flatten_array (@{ $_[0] }) ] }
	q (list)
	;

assume q (flatten_array () should flatten all (even nested) arrayrefs)
	=> expect    => [ 1, 2, 3, 4, 5, 6, 7 ],
	=> with_list => [
		1,
		[
			[
				2,
				[ 3 ],
			],
			[ 4 ],
		],
		[
			5,
			[ 6 ],
			[ [ 7 ] ],
		],
	];

assume q (flatten_array () should pass-through list without direct arrayrefs)
	=> with_list => [ 1, { 2 => [ 3 ] } ],
	=> expect    => [ 1, { 2 => [ 3 ] } ],
	;

assume q (flatten_array () should pass-through empty list)
	=> with_list => [ ],
	=> expect    => [ ],
	;

had_no_warnings;
done_testing;
