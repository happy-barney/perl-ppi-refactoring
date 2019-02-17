
use strict;
use warnings;

use Test::More;
use Test::Warnings;

use Shared::Examples::PPIx::Utils qw[ behaves_like_element_classification ];

use HPB::PPIx::Utils;

sub do_test {
	my ($title, %params) = @_;

	my $document = PPI::Document->new (\ $params{snippet} );
	my ($call) = ppix_find ($document, where { is_ppi_token_word ($_, 'call') });

	my @got = find_function_call_arguments ($call);

	use Data::Printer;
	is_deeply
		[ map { local $" = ''; "@$_" } @got ],
		$params{expect},
		$title
		or p @got;
}

do_test "method call without arguments" => (
	snippet => '$self->call',
	expect => [],
);

do_test "method call with argument-less methods" => (
	snippet => '$self->call ($self->foo, $self->bar)',
	expect => [
		'$self->foo',
		'$self->bar',
	],
);

do_test "method call with some arguments" => (
	snippet => '$self->call ( 1 , $self->bar (2),)',
	expect => [
		'1',
		'$self->bar (2)',
	],
);

do_test "method call with fat comma arguments" => (
	snippet => '$self->call ( 1 , bar => $self->bar (2),)',
	expect => [
		'1',
		'bar',
		'$self->bar (2)',
	],
);

done_testing;
