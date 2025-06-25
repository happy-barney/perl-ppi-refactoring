#!/usr/bin/env perl

use v5.14;
use warnings;

package App::ppi_sanity::attributes {
	use Exporter q (import);

	use Attribute::Handlers;

	BEGIN {
		our @EXPORT = (
			q (policy_apply),
			q (policy_list),
			q (policy_list_default),
			q (policy_search),
		);
	}

	my %POLICIES;

	sub _normalise_policy_name ($);

	sub Default                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $key = _normalise_policy_name *{$symbol}{NAME};

		$POLICIES{$key}{default} = 1;
	}

	sub Policy                          :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};
		my $key = _normalise_policy_name $name;

		$POLICIES{$key}{name}    = $name;
		$POLICIES{$key}{handler} = $referent;
		$POLICIES{$key}{key}     = $key;
	}

	sub _build_character_lookup_regex {
		my $regex = join q (.*-) => split q (), shift;

		return qr (^$regex);
	}

	sub _build_component_lookup_regex {
		my $regex = join q (.*-) => split q (-), shift;

		return qr (^$regex);
	}

	sub _normalise_policy_name ($) {
		lc shift
			=~ s (^policy_) ()r
			=~ tr [_] [-]r
	}

	sub policy_apply {
		my $name = shift;

		return
			unless my $spec = $POLICIES{$name}
			;

		$spec->{handler}->(@_);
	}

	sub policy_list {
		return sort keys %POLICIES;
	}

	sub policy_list_default {
		return sort grep { $_->{default} } keys %POLICIES;
	}

	sub policy_search {
		my $name = _normalise_policy_name (shift);

		return $name
			if exists $POLICIES{$name}
			;

		for my $regex (
			_build_component_lookup_regex ($name),
			_build_character_lookup_regex ($name),
		) {
			my @matches = grep { $_ =~ $regex } keys %POLICIES;

			return $matches[0]
				if @matches == 1
				;
		}

		return undef;
	}

	1;
}

package App::ppi_sanity {
	BEGIN {
		App::ppi_sanity::attributes->import;
	}

	sub run {
		return 0;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;

1;
