
use v5.16;
use warnings;

use Test::More;

use require::relative "test-helper.pl";

use HPB::PPIx::Utils qw[ is_method_call ];

behaves_like_element_classification 'it should find method calls'
	=> classification => where { is_method_call }
	=> expected       => [
		'method',
		'with_arguments',
	]
	=> document       => \ <<'		CODE',
		$self->method;
		$self->with_arguments ();
		CODE
	;

behaves_like_element_classification 'it should find some obscure method calls'
	=> classification => where { is_method_call }
	=> expected       => [
		'with_spaces',
		'with_comment_and_spaces',
	]
	=> document       => \ <<'		CODE',
		$self -> with_spaces;
		$self -> #
		with_comment_and_spaces;
		CODE
	;

behaves_like_element_classification 'it should find method call by reference'
	=> classification => where { is_method_call }
	=> expected       => [
		'$foo',
		'$',
	]
	=> document       => \ <<'		CODE',
		$self->$foo;
		$self->${\ $bar};
		CODE
	;

behaves_like_element_classification 'it should not recognize dereference as method call'
	=> classification => where { is_method_call }
	=> expected       => [
	]
	=> document       => \ <<'		CODE',
		$self->{foo};
		$self->[foo];
		$self->(foo);
		$self->$*;
		$self->%*;
		CODE
	;

done_testing
