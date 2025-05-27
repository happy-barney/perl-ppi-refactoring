
use v5.14;
use warnings;

use Carp::Always; # collides with Test::Warning's $SIG{__WARN__}

use PPI v1.278;
use PPI::Dumper;

use Test::YAFT;

{
	### TODO: move to Test::YAFT

	no warnings q (once);

	*assume = \ &it
		unless __PACKAGE__->can (q (assume))
		;

	*expect = sub (&) { expect => shift->() }
		unless __PACKAGE__->can (q (expect))
		;

	*expect_defined = sub { ! expect_value (undef) }
		unless __PACKAGE__->can (q (expect_defined))
		;

	*expect_method = \ &expect_methods
		unless __PACKAGE__->can (q (expect_method))
		;
}

sub distribution_root;
sub fixture_path;
sub fixture_root;
sub ppi_document;
sub tests_root;

sub distribution_root {
	return tests_root->parent;
}

sub fixture {
	return fixture_path (@_)->slurp_utf8;
}

sub fixture_list {
	my $root = fixture_root;

	return map { $_->relative ($root) } $root->children;
}

sub fixture_path {
	return fixture_root ()->child (@_);
}

sub fixture_root {
	return tests_root->child (q (fixture));
}

sub ppi_document {
	my ($source) = @_;

	return
		unless defined $source
		;

	return $source
		if ref $source && $source->isa (PPI::Document::)
		;

	$source = qq ($source)
		if ref $source
		;

	PPI::Document::->new (
		($source =~ m/\n/ || ! -e $source)
			? \ $source
			: $source
		);
}

sub ppi_dump {
	diag (PPI::Dumper::->new ($_)->string =~ s ((?<= [#])) (    )xr)
		for
		map { ppi_document ($_) }
		map { Ref::Util::is_plain_arrayref ($_) ? @$_ : $_ }
		@_
		;
}

sub tests_root {
	return Path::Tiny::->new (__FILE__)->parent;
}

1;

