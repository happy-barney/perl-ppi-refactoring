
use v5.14;
use warnings;

use Carp::Always; # must be before Test::YAFT - replaces $SIG{__WARN__}

use Context::Singleton;
use Path::Tiny qw ();
use PPI v1.277;
use PPI::Dumper;
use Ref::Util;
use Safe::Isa;
use Scalar::Util;
use Test::YAFT qw (:all), it => { -as => q (assume) };

use PPIx::Augment;
use PPIx::Augment::Utils;

sub distribution_root;
sub tests_root;

### ############################################################

sub distribution_root {
	return tests_root->parent;
}

sub tests_root {
	return path (__FILE__)->parent;
}

1;

