#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::Util qw[ max ];
use Path::Tiny;
use Path::Iterator::Rule;
use PPIx::Augment;
use PPIx::Refactoring;
use MCE;

my @queue =
	Path::Iterator::Rule
	->new
	->file
	->name (qr/\.(?:pm|pl|t)$/)
	->all (@ARGV ? @ARGV : '.', { recurse => 1 })
	;

my @refactorings = (
	#[ 'veure::json-constants', 'true' ],
	#[ 'veure::json-constants', 'false' ],
	#[ 'eliminate-cache-variable', 'json_true' ],
	[ 'eliminate-cache-variable', 'json_false' ],
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

	eval {
		my $document = PPI::Document->new ("$_");
		my $refactoring = PPIx::Refactoring->new ("$_");

		$refactoring->refactor (@$_) for @refactorings;

		if ($refactoring->{modified}) {
			MCE->say ("Modify $_");
			$refactoring->save;
		}
		1;
	} // MCE->say ("Failed $_\n$@");
} @queue;


my $finish_time = [Time::HiRes::gettimeofday];

say "Process ${\ scalar @queue } files in ${\ tv_interval ($start_time, $finish_time) } seconds";

