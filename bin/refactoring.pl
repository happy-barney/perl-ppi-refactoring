#!/usr/bin/env perl

use v5.16;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use HPB::PPIx::Refactoring qw[ document refactor ];

use Path::Tiny qw[];

my @args = @ARGV
	? map Path::Tiny->new ($_), @ARGV
	: Path::Tiny->new ('.')
	;

while (my $file = shift @args) {
	say "=> $file";
	if (-d $file) {
		unshift @args, $file->children;
		next;
	}

	my $document = document ($file->stringify);

	my $modified = refactor $document, 'find_json_boolean';

	if ($modified) {
		say "   modified";
		open my $fh, '>', $file
			or die "cannot write to $file";

		select $fh;
		print $document->serialize;
		select STDOUT;
	}
}

