
use strict;
use warnings;

use Test::More;
use Test::Warnings;

use Shared::Examples::PPIx::Utils qw[ behaves_like_element_classification ];

use PPIx::Utils qw[ is_method_call ];
use HPB::PPIx::Utils qw[ is_invocant ];

behaves_like_element_classification 'it should find property invocant' => (
	classification => \& is_invocant,
	expected       => [
		'$self',
	],
	document       => \ <<'CODE',
		$self->r;
CODE
);

behaves_like_element_classification 'it should find chained property invocants' => (
	classification => \& is_invocant,
	expected       => [
		'$self',
		'r',
	],
	document       => \ <<'CODE',
		$self->r->method;
CODE
);

behaves_like_element_classification 'it should find method invocant' => (
	classification => \& is_invocant,
	expected       => [
		'$self',
	],
	document       => \ <<'CODE',
		$self->r();
CODE
);

behaves_like_element_classification 'it should find chained method invocants' => (
	classification => \& is_invocant,
	expected       => [
		'$self',
		'r',
	],
	document       => \ <<'CODE',
		$self->r()->method;
CODE
);

done_testing;
