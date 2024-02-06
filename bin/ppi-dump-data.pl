#!/usr/bin/env perl

use v5.14;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use PPI::Dumper;
use List::Util qw[ max ];
use Path::Tiny;
use PPIx::Augment;
use PPIx::Augment::Utils;
use MCE;

my @queue;
my @list = map { Path::Tiny->new ($_) } @ARGV ? @ARGV : '.';

my %stats;

while (my $head = shift @list) {
	unshift @list, $head->children and next
		if -d $head;

	next
		unless $head =~ m/\.(?:pm|pl|t)$/;

	push @queue, $head;
}

use MCE::Loop;

MCE::Loop->init (
	max_workers => 28,
	chunk_size => 1
);


my @res = mce_loop {
	my $file = "$_";
	my $document = PPI::Document->new ($file);
	ppix_process $document
		=> where  { it_is_operator_arrow }
		=> where  { its_sprevious_sibling { it_is 'PPI::Structure::Constructor' } }
		=> invoke {
			MCE->gather ([
				$file,
				$_->parent->content,
				PPI::Dumper->new ($_->parent)->string,
			]);
		}
		;
} @queue;

for (@res) {
	my ($file, $content, $dump) = @$_;
	say $file;
	say '=' x 70;
	say $content;
	say '';
	say $dump;
}

__END__

lhs PPI::Token::Cast            - 1
lhs PPI::Token::Quote::Double   - 3
lhs PPI::Structure::Block       - 6
lhs PPI::Structure::Constructor - 9
lhs PPI::Token::Magic           - 1859
lhs PPI::Structure::Subscript   - 2359
lhs PPI::Structure::List        - 4396
lhs PPI::Token::Word            - 22900
lhs PPI::Token::Symbol          - 86248

rhs PPI::Structure::List        - 1166
rhs PPI::Structure::Subscript   - 12781
rhs PPI::Token::Cast            - 2352
rhs PPI::Token::Label           - 102
rhs PPI::Token::Magic           - 153
rhs PPI::Token::Symbol          - 735
rhs PPI::Token::Word            - 100492
