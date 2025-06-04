#!/usr/bin/env perl

use v5.14;
use warnings;

use utf8;


use PPI;

sub dist_ini;
sub dist_package;
sub dist_root;

sub dist_ini {
	state $dist_ini = do {
		require Config::INI::Reader;
		Config::INI::Reader->read_file (
			dist_root->child (q (dist.ini))
		);
	};
}

sub dist_root {
	state $dist_root = do {
		require Path::Tiny;
		my $pwd = Path::Tiny::->cwd;

		while (1) {
			$pwd = undef
				if $pwd eq $pwd->rootdir
				;

			last
				if ! defined $pwd
				|| $pwd->child (q (.git))->exists
				|| $pwd->child (q (dist.ini))->exists
				;

			$pwd = $pwd->parent;
		}

		$pwd;
	};
}

sub dist_package {
	state $dist_package = do {
		dist_ini->{_}{name} =~ s ([-]) (::)gr;
	};
}

say dist_package;
