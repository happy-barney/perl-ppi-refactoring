
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

use PPIx::Augment::Internals;

package Foo {
}

package Bar {
	our @ISA = qw (Foo);
}

assume q (ensure_isa () should push new base class)
	=> expect { [ qw (Baz) ] }
	=> got    {
		my ($into, $base) = (Foo::, q (Baz));

		PPIx::Augment::Internals::ensure_isa ($base, $into);

		\ @Foo::ISA;
	}
	;

assume q (ensure_isa () shouldn't push existing parent)
	=> expect { [ q (Foo) ] }
	=> got    {
		my ($into, $base) = (Bar::, q (Foo));

		PPIx::Augment::Internals::ensure_isa ($base, $into);

		\ @Bar::ISA;
	}
	;

had_no_warnings;
done_testing;
