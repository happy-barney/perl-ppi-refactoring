
use v5.14;
use warnings;

package PPIx::Augment::DOM::Token {
	use parent qw (PPIx::Augment::DOM::Element PPI::Token);

	use Safe::Isa q ($_isa);

	sub identify {
		my ($class, $element) = @_;

		return
			unless $element->$_isa ($self->ppi_class)
			;


		return $element->content =~ $self->
		unless $element->isa (PPIx::Augment::DOM::Element::)
			;

		return $element->isa (__PACKAGE__)


		if ($element->$_isa (PPIx::Augment::DOM::Element::)) {
			

	1;
;
}
