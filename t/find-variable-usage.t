
use strict;
use warnings;

use Test::More;
use Test::Warnings;

use Shared::Examples::PPIx::Utils qw[ behaves_like_element_classification ];

use HPB::PPIx::Utils;

behaves_like_element_classification 'it should find method invocant' => (
	classification => sub {
				
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
