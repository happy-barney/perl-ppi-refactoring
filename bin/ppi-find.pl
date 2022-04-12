#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::Util qw[ max ];
use Path::Tiny;
use Path::Iterator::Rule;
use PPIx::Augment;
use PPIx::Augment::Utils;
use MCE;

my @queue =
	Path::Iterator::Rule
	->new
	->file
	->name (qr/\.(?:pm|pl|t)$/)
	->all (@ARGV ? @ARGV : '.', { recurse => 1 })
	;

use MCE::Loop;

MCE::Loop->init (
	max_workers => MCE::Util::get_ncpu,
	chunk_size => 1
);

use Time::HiRes qw[ gettimeofday tv_interval ];

my $start_time = [gettimeofday];

mce_loop {
	my ($mce, $chunk_ref, $chunk_id) = @_;

	$0 = "[ppi-refactoring] $_";

	eval {
		my $document = PPIx::Augment->new ("$_");

		ppix_process $document
			=> where { it_is_token_word qr/\b(true|false)$/ }
			=> invoke {
				MCE->say (join ': ', find_filename, $_->line_number, $_)
			};

		1;
	} // MCE->say ("Failed $_\n$@");
} @queue;


my $finish_time = [Time::HiRes::gettimeofday];

say "Process ${\ scalar @queue } files in ${\ tv_interval ($start_time, $finish_time) } seconds";

