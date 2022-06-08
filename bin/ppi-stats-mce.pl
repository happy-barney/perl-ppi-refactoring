#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use List::Util qw[ max ];
use Path::Tiny;
use PPIx::Augment;
use MCE;
use MCE::Util;

sub task_list_files {
	my @list = map { Path::Tiny->new ($_) } @_ ? @_ : '.';

	while (my $head = shift @list) {
		unshift @list, $head->children and next
			if -d $head;

		next
			unless $head =~ m/\.(?:pm|pl|t)$/;

		$queue->enqueue ($head);
	}
}

sub it_extends_veure_controller {
	#use Test::Class::Moose extends => 'TestsFor::Veure::Controller';

	

	{
		local $_ = $_;
		
	}
}

my %stats;

use MCE::Loop;

MCE::Loop->init (
	max_workers => MCE::Util::get_ncpu,
	chunk_size => 1
);

my @res = mce_loop {
	my ($mce, $chunk_ref, $chunk_id) = @_;
	my %stats;

	my $document = PPIx::Augment->new ("$_");
	ppix_process $document
		=> where  { it_is_statement_package }
		=> invoke {
			MCE->say ("=> ", $_->namespace );
		}
		;

	#MCE->gather (\ %stats) if %stats;
} @queue;

__END__
for my $res (@res) {
	for my $key (keys %$res) {
		$stats{$key} += $res->{$key};
	}
}

my $length = max map { length } keys %stats;

for my $key (sort keys %stats) {
	printf "%-*s - %d\n", $length, $key, $stats{$key};
}

