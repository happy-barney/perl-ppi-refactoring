#!/usr/bin/env perl

use v5.14;
use strict;

package App::ppi_sanity {
	use Attribute::Handlers;

	my %POLICIES_ALL;

	sub Default                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};

		$POLICIES_ALL{$name}{default} = 1;
	}

	sub Policy                          :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};

		$POLICIES_ALL{$name}{name}    = $name;
		$POLICIES_ALL{$name}{handler} = $referent;
		$POLICIES_ALL{$name}{key}     = $name =~ s (^policy_) ()r =~ tr [_] [-]r,
	}

	sub run {
		return 0;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;
