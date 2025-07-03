#!/usr/bin/env perl

use v5.14;
use strict;

package App::ppi_sanity {
	use Attribute::Handlers;
	use List::Util;
	use POSIX qw (strftime);
	use Term::ANSIColor qw ();

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

	my $color_theme = {
		ERROR => q (red),
		WARN  => q (magenta),
		INFO  => undef,
		DONE  => q (green),
		TRACE => q (cyan),
	};

	my $log_use_color = -t STDOUT;
	my $log_verbose   = 0;
	my $log_with_time = 1;

	sub log_done (&);
	sub log_error (&);
	sub log_info (&);
	sub log_verbose (&);
	sub log_warning (&);

	sub _colored {
		my ($semantic_color, @what) = @_;

		return @what
			unless $log_use_color
			&& (my $color = $color_theme->{$semantic_color})
			;

		return Term::ANSIColor::colored ([ $color ], @what);
	}

	sub _log {
		my ($level, $code) = @_;

		return
			unless my @message = $code->()
			;

		state $length = List::Util::max (map { length } keys %$color_theme);

		local $, = q ( );
		say
			$log_with_time ? strftime (q ([%T]), localtime) : (),
			_colored ($level, sprintf q (%-*s), $length, $level),
			@message
			;
	}

	sub log_done (&) {
		_log DONE => @_;
	}

	sub log_error (&) {
		_log ERROR => @_;
	}

	sub log_info (&) {
		_log INFO => @_;
	}

	sub log_verbose (&) {
		_log TRACE => @_
			if $log_verbose
			;
	}

	sub log_warning (&) {
		_log WARN => @_;
	}

	sub run {
		return 0;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;
