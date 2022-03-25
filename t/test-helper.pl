
use v5.14;
use warnings;

use Test::More import => [qw[ !ok !is !is_deeply ]];
use Test::Deep qw[!cmp_deeply !cmp_bag !cmp_set !cmp_methods];
use Test::Differences qw[];
use Test::Warnings qw[ :no_end_test had_no_warnings ];

use Safe::Isa;

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

1;

