
use strict;
use warnings;

use Test::More;
use Test::Warnings;

use PPIx::Utils qw[ is_method_call ];
use HPB::PPIx::Utils (
	qw[ is_method_call_on ],
	qw[ where ],
);

BEGIN { require "test-helper.pl" };

plan tests => 2;

expect_find "should find method call on named variable" => (
	expected => [qw[ bar ]],
	where => where {
		is_method_call_on ($_, '$self')
	},
	code => <<'CODE',
		$that->foo;
		$self->bar;
CODE
);
