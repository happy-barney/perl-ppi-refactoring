
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw[ :no_end_test had_no_warnings ];

plan tests => 2;

use_ok 'PPIx::Augment';

had_no_warnings;

done_testing;
