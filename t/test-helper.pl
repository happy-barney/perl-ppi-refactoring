
use v5.14;
use warnings;

use Path::Tiny;

use Test::YAFT q (:default), { it => q (assume) };

sub __FILE__DIR__ () {
	Path::Tiny::->new ((caller)[1])->parent;
}

1;

