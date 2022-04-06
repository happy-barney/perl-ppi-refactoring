
use v5.14;
use warnings;

use require::relative 'test-helper-fixture.pl';

use Test::More import => [qw[ !ok ]];
use Test::Deep qw[!cmp_deeply !cmp_bag !cmp_set !cmp_methods];
use Test::Differences qw[];
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Safe::Isa;
use Scalar::Util qw[];
use Sub::Install qw[];

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

sub test_deep_cmp {
	my (%methods) = @_;

	state $serial = 0;
	my $prefix = 'Test::Deep::Cmp::__ANON__::';

	my $class = $prefix . ++$serial;
	my $isa = delete $methods{isa} // _test_deep_cmp_val ();

	$isa = join ' ', Ref::Util::is_arrayref $isa ? @$isa : $isa;
	eval "package $class; use parent qw[ $isa ];";

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

