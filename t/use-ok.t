
use v5.14;
use warnings;

use Test::More;
use Test::Warnings qw[ :no_end_test had_no_warnings ];

plan tests => 4;

use_ok 'PPIx::Augment';
use_ok 'PPIx::Augment::Elements';
use_ok 'PPIx::Augment::Utils';

had_no_warnings;

done_testing;
