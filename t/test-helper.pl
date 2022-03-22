
use v5.14;
use warnings;

use require::relative 'test-helper-fixture.pl';

use Test::More import => [qw[ !ok ]];
use Test::Deep qw[!cmp_deeply !cmp_bag !cmp_set !cmp_methods];
use Test::Differences qw[];
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Ref::Util qw[];
use Safe::Isa;
use Scalar::Util qw[];
use Sub::Install qw[];
use Sub::Override;

use PPI;
use PPI::Dumper;

use PPIx::Augment;
use PPIx::Augment::Utils;

sub augmented_document {
	PPIx::Augment->augment (document (@_));
}

sub check_ppi {
	my ($title, %params) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	my $got = my $found = $params{got};

	unless (exists $params{got}) {
		$got = $params{document} // $params{element};
		$got = augmented_document ($got) unless $got->$_isa ('PPI::Element');
		$found = $got;

		my $where = $params{where};

		if (my $where_first = $params{first}) {
			$where = sub { state $i = 0; $where_first->(@_) && ($i++ > 0 ? undef : 1) };
		}

		if ($where) {
			$found = [ ppix_find ($got, $where) ];
		}
	}

	it ($title
		=> got    => $found
		=> expect => $params{expect}
	) or do {
		diag (PPI::Dumper->new ($_)->string)
			for Ref::Util::is_plain_arrayref ($got) ? @$got : $got
	};
}

sub document {
	my ($source) = @_;
	return $source if ref $source && $source->isa (PPI::Document::);

	$source = $source->stringify
		if $source->$_isa ('Path::Tiny');

	PPI::Document->new (
		$source =~ m/\n/ || ! -e $source
			? \ $source
			: $source
		);
}

sub expect_element {
	my ($class, @children) = @_;

	my $expectation = expect_instance_of ($class);

	$expectation &= Test::Deep::methods (content => shift @children)
		if @children && ! ref $children[0];

	$expectation &= Test::Deep::listmethods (children => shift @children)
		if @children == 1 && Ref::Util::is_plain_arrayref ($children[0]);

	$expectation &= Test::Deep::listmethods (children => \ @children)
		if @children;

	return $expectation;
}

sub expect_instance_of {
	my ($namespace) = @_;

	state $class = test_deep_cmp (
		isa             => [ 'Test::Deep::Obj' ],
		descend         => sub {
			my ($self, $got) = @_;
			return $self->Test::Deep::Obj::descend ($got) && ref ($got) eq $self->{val};
		},
		diag_message    => sub {
			my ($self, $where) = @_;
			return "Checking instance type of $where";
		},
		renderGot       => sub {
			my ($self, $got) = @_;

			return $self->Test::Deep::Obj::renderGot ($got)
				unless Scalar::Util::blessed ($got);
			return "blessed into '${\ ref $got }'";
		},
		renderExp       => sub {
			my ($self) = @_;
			return "blessed into '$self->{val}'";
		},
	);

	return $class->new ($namespace);
}

sub expect_nodeset {
	return [ @_ ];
}

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

	it ($title, %args);
}

sub nok {
	my ($title, %args) = @_;

	local $Test::Builder::Level = $Test::Builder::Level + 1;

	$args{expect} = bool (0);

	it ($title, %args);
}

sub test_deep_cmp {
	my (%methods) = @_;

	state $serial = 0;
	my $prefix = 'Test::Deep::Cmp::__ANON__::';

	my $class = $prefix . ++$serial;
	my $isa = delete $methods{isa} // _test_deep_cmp_val ();

	{
		my @isa = Ref::Util::is_arrayref ($isa) ? @$isa : ($isa);
		eval "require $_" for @isa;

		no strict 'refs';
		@{ "$class\::ISA" } = @isa;
	}

	Sub::Install::install_sub ({ into => $class, as => $_, code => $methods{$_} })
		for keys %methods;

	return $class;
}

sub _test_deep_cmp_val {
	state $class = test_deep_cmp (
		isa  => [ 'Test::Deep::Cmp' ],
		init => sub { $_[0]->{val} = $_[1] },
	);
}

1;

