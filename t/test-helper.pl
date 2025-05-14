
use v5.14;
use warnings;

use Carp::Always; # must be before Test::YAFT - replaces $SIG{__WARN__}

use Context::Singleton;
use PPI v1.278;
use Path::Tiny;
use Safe::Isa;
use Test::YAFT qw (:all);

{
	### TODO: functions which should be available in respective modules
	### TODO: move them there

	no warnings q (once);

	*assume = \ &it
		unless __PACKAGE__->can (q (assume))
		;

	*deduce_undef = sub { return try_deduce (@_) ? undef : deduce (@_) }
		unless __PACKAGE__->can (q (deduce_undef))
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
sub ppi_document;
sub tests_root;

sub distribution_root {
	return tests_root->parent;
}

sub ppi_document {
	my ($source) = @_;

	return
		unless defined $source
		;

	return $source
		if $source->$Safe::Isa::_isa (PPI::Element::)
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

sub tests_root {
	return Path::Tiny::->new (__FILE__)->parent;
}

1;

