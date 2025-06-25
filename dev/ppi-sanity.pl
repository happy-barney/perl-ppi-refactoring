#!/usr/bin/env perl

use v5.14;
use strict;

package App::ppi_sanity {
	sub run {
		return 0;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;
