
use v5.14;
use warnings;

use Carp::Always; # must be before Test::YAFT - replaces $SIG{__WARN__}

use Context::Singleton;
use Path::Tiny qw ();
use PPI v1.277;
use PPI::Dumper;
use Safe::Isa;
use Scalar::Util;
use Ref::Util  qw (is_plain_arrayref);
use Safe::Isa  qw ();
use Test::YAFT qw (:all), it => { -as => q (assume) };

use PPIx::Augment;
use PPIx::Augment::Utils;

### ############################################################

my $SINGLETON_CLASSIFICATION = q (arrange-testing-classification);

### ############################################################

sub deduce_undef;
sub distribution_root;
sub tests_root;

### ############################################################

sub _build_argument_caller_value {
	my ($caller, $what) = @_;

	$what = $_->()
		for grep { $_ } $caller->$Safe::Isa::_can ($what)
		;

	return $what;
}

sub _build_argument_function {
	my ($caller, $function, $singleton, @custom_args) = @_;

	$function
		//= deduce_undef ($singleton)
		// return
		;

	my @args;

	($function, @args) = @$function
		if is_plain_arrayref ($function)
		;

	$function = _build_argument_caller_value ($caller, $function);

	return sub { $function-> (@_, @args, @custom_args) };
}

sub build_expect (\%) {
	my ($args) = @_;

	return _build_argument_caller_value ($args->{caller}, $args->{expect});
}

sub build_tested_classification (\%) {
	my ($args) = @_;

	return _build_argument_function (
		$args->{caller} // caller,
		$args->{classification},
		$SINGLETON_CLASSIFICATION,
		@{ $args->{conditions} // $args->{with} // [] }
	)
		// die q (Argument 'classification' must be specified)
		;
}

sub deduce_undef {
	my ($singleton) = @_;

	return undef
		unless defined $singleton
		;

	return undef
		unless try_deduce $singleton
		;

	return deduce $singleton;
}

sub distribution_root {
	return tests_root->parent;
}

sub testing_classification (&) {
	proclaim $SINGLETON_TESTING_CLASSIFICATION => shift;
}

sub tests_root {
	return path (__FILE__)->parent;
}

1;

