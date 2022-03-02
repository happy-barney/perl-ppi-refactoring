
use strict;
use warnings;

use Test::More;
use Test::Warnings;

use PPIx::Utils qw[ is_method_call ];
use HPB::PPIx::Utils (
	qw[ has_no_arguments ],
	qw[ where ],
);

BEGIN { require "test-helper.pl" };

plan tests => 2;

expect_find "should find method call without arguments" => (
	expected => [qw[ foo bar baz ]],
	where => where {
		is_method_call ($_) #&& has_no_arguments ($_)
	},
	code => <<'CODE',
		$self->foo;
		$self->bar(1);
		$self->baz();
CODE
);
