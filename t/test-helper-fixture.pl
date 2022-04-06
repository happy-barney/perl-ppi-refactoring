
use v5.14;
use warnings;

use Path::Tiny qw[];

sub fixture_root {
	return Path::Tiny->new (__FILE__)->parent->child ('fixture');
}

sub fixture_path {
	return fixture_root ()->child (@_);
}

sub fixture {
	return fixture_path (@_)->slurp_utf8;
}

sub fixture_list {
	my $root = fixture_root;

	return map { $_->relative ($root) } $root->children;
}

1;

