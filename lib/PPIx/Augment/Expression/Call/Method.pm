
use v5.10;
use strict;
use warnings;

package PPIx::Augment::Expression::Call::Method;

use PPIx::Augment::Token::Operator::Arrow;

use parent 'PPI::Statement::Expression';

sub augment_element {
	my ($self, $element) = @_;

	PPIx::Augment::Token::Operator::Arrow->augment_element ($element);
}

1;
