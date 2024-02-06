#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::Util qw[ max ];
use Path::Tiny;
use PPIx::Augment::Utils;

my @list = map { Path::Tiny->new ($_) } @ARGV ? @ARGV : '.';

my %stats;

while (my $head = shift @list) {
	unshift @list, $head->children and next
		if -d $head;

	next
		unless $head =~ m/\.(?:pm|pl|t)$/;

	my $document = PPI::Document->new ($head->stringify);
	ppix_process $document
		=> where  { it_is_operator_arrow }
		=> invoke {
			$stats{'lhs/' . ref $_->sprevious_sibling}++;
			$stats{'rhs/' . ref $_->snext_sibling}++;
		}
		;
}

my $length = max map { length } keys %stats;

for my $key (sort keys %stats) {
	printf "%-*s - %d\n", $length, $key, $stats{$key};
}

