
use v5.14;
use warnings;

package PPIx::Augment::DOM::Token::Number::Decimal {
	use parent qw (PPIx::Augment::DOM::Token::Number);

	use Safe::Isa q ($_isa);

	use constant value_regex => qr (\G \b (?! 0 \B ) [0-9]+ \b)x;
	use constant ppi_class   => PPI::Token::Number::;

	sub identify {
		my ($class, $element) = @_;

		return
			unless $element->$_isa (PPI::Token::Number::)
			;

		return $element->content =~ $self->
		unless $element->isa (PPIx::Augment::DOM::Element::)
			;

		return $element->isa (__PACKAGE__)


		if ($element->$_isa (PPIx::Augment::DOM::Element::)) {
			

	1;
;
}
