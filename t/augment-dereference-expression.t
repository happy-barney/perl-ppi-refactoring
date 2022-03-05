
use v5.16;
use warnings;

use Test::More;

use require::relative "test-helper.pl";

use HPB::PPIx::Utils qw[ is_method_call ];
use HPB::PPIx::Refactoring qw[ document ];

behaves_like_element_classification 'it should augment method calls'
	=> classification => where { $_->isa ('PPIx::Augment::Expression::Dereference') }
	=> expected       => [
		'$self->method',
		'foo->method',
		'$self->$method',
		'$self->$',
	]
	=> document       => document \ <<'		CODE',
		$self->method;
		foo->method;
		$self->$method;
		$self->${\ "method" };
		CODE
	;

behaves_like_element_classification 'it should augment method chain (recursively)'
	=> classification => where { $_->isa ('PPIx::Augment::Expression::Dereference') }
	=> expected       => [
		'$self->foo->bar',
		'$self->foo',
	]
	=> document       => document \ <<'		CODE',
		$self->foo->bar;
		CODE
	;

behaves_like_element_classification 'it should prevent spaces'
	=> classification => where { $_->isa ('PPIx::Augment::Expression::Dereference') }
	=> expected       => [
		'$self ->foo-> bar',
		'$self ->foo',
	]
	=> document       => document \ <<'		CODE',
		$self ->foo-> bar;
		CODE
	;

behaves_like_element_classification 'it should recognize subscripted derefence'
	=> classification => where { $_->isa ('PPIx::Augment::Expression::Dereference') }
	=> expected       => [
		'$foo->{bar}[baz]',
		'$foo->{bar}',
	]
	=> document       => document \ <<'		CODE',
		$foo->{bar}[baz]
		CODE
	;

behaves_like_element_classification 'it should recognize coderef dereference'
	=> classification => where { $_->isa ('PPIx::Augment::Expression::Dereference') }
	=> expected       => [
		'$foo->{bar}[baz]',
		'$foo->{bar}',
	]
	=> document       => document \ <<'		CODE',
		$foo->{bar}[baz]
		CODE
	;

done_testing
