#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::Util qw[ max ];
use Path::Tiny;
use PPIx::Augment;
use PPIx::Refactoring;
use MCE;

my @queue;
my @list = map { Path::Tiny->new ($_) } @ARGV ? @ARGV : '.';

while (my $head = shift @list) {
	unshift @list, $head->children and next
		if -d $head;

	next
		unless $head =~ m/\.(?:pm|pl|t)$/;

	push @queue, $head;
}

my @refactorings = (
	[ 'veure::json-constants' ],
	#[ 'veure::eliminate-direct-json-import' ],
);

PPIx::Refactoring->find_refactoring (@$_) for @refactorings;

use MCE::Loop;

my ($cpu_count) = `nproc --all`;
chomp $cpu_count;

MCE::Loop->init (
	max_workers => 1 + int (1.2 * $cpu_count),
	chunk_size => 1
);

use Time::HiRes qw[ gettimeofday tv_interval ];

my $start_time = [gettimeofday];

mce_loop {
	my ($mce, $chunk_ref, $chunk_id) = @_;

	$0 = "[ppi-refactoring] $_";

	my $document = PPIx::Augment->augment (PPI::Document->new ("$_"));

	my $refactoring = PPIx::Refactoring->new ("$_");

	$refactoring->refactor (@$_) for @refactorings;

	MCE->say ("Modify $_") if $refactoring->{modified};
	$refactoring->save;
} @queue;


my $finish_time = [Time::HiRes::gettimeofday];

say "Process ${\ scalar @queue } files in ${\ tv_interval ($start_time, $finish_time) } seconds";

