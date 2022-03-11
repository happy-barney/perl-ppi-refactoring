
use v5.14;
use warnings;

use Test::More import => [qw[ !ok ]];
use Test::Deep qw[!cmp_deeply !cmp_bag !cmp_set !cmp_methods];
use Test::Differences qw[];
use Test::Warnings qw[ :no_end_test had_no_warnings ];
use Hash::Util;

use Safe::Isa;

use PPI;
use PPI::Dumper;

use PPIx::Augment;
use PPIx::Augment::Utils;
use PPIx::Augment::Nodeset;

sub it {
	my ($title, %args) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	die "got not provided" unless exists $args{got};
	die "expect not provided" unless exists $args{expect};

	if ($args{expect}->$_isa (Test::Deep::Boolean::)) {
		return Test::More::ok (($args{got} xor ! $args{expect}{val}), $title);
	}

	my ($ok, $stack) = Test::Deep::cmp_details ($args{got}, $args{expect});

	return pass $title
		if $ok;

	Test::Differences::eq_or_diff ($args{got}, $args{expect}, $title);
	diag Test::Deep::deep_diag ($stack);

	return;
}

sub ok {
	my ($title, %args) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	$args{expect} = bool (1);

	it $title, %args;
}

sub check_ppi {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = $params{document} // $params{element};
	$got = augmented_document (\ $got) unless ref $got;

	if (my $where = $params{where} // $params{where_first}) {
		my @found = ppix_find ($got, $where);

		$got = $params{where_first} ? $found[0] : PPIx::Augment::Nodeset->new (map $_->clone, @found);
	}

	it $title
		=> got    => $got
		=> expect => $params{expect},
		or do {
			diag (PPI::Dumper->new ($_)->string)
				for Ref::Util::is_plain_arrayref ($got) ? @$got : $got
		}
	;
}

sub document {
	PPI::Document->new (shift);
}

sub augmented_document {
	PPIx::Augment->augment (document @_);
}

sub expect_element {
	my ($class, @children) = @_;

	my $expectation = Test::Deep::obj_isa ($class);

	$expectation &= Test::Deep::methods (content => shift @children)
		if @children && ! ref $children[0];

	$expectation &= Test::Deep::listmethods (children => \ @children)
		if @children;

	return $expectation;
}

sub behaves_like_ppi_find {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	Hash::Util::lock_keys %params, qw[ find document expected ];

	my $document = $params{document}->$_isa ('PPI::Document')
		? $params{document}
		: PPI::Document->new ($params{document})
		;

	my $got = $document->find ($params{find}) || [];

	is_deeply ($got, $params{expected}, $title)
		or do { PPI::Dumper->new ($document)->print };
}

sub behaves_like_element_classification {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	Hash::Util::lock_keys %params, qw[ classification document expected ];

	behaves_like_ppi_find ($title => (
		find     => sub { $params{classification}->(local $_ = $_[1]) },
		document => $params{document},
		expected => $params{expected},
	));
}
sub behaves_like_element_lookup {
	my ($title, %params) = @_;

	Hash::Util::lock_keys %params, qw[ code where expected ];

	my $document = PPI::Document->new (\ $params{code});

	my @got = HPB::PPIx::Utils::ppix_find ($document, $params{where});

	is_deeply \@got, $params{expected}, $title;
}

1;

