
use v5.14;
use warnings;

package PPIx::Augment::Augmentation::Elements {

	use PPIx::Augment::Augmentation;
	use PPIx::Augment::Utils;

	use namespace::clean;

	my %augment_map = (
		PPI::Token::Word:: => [
		],
	);

	declare augmentation
		=> where  { ppix_include }
		=> invoke {
			for my $ppi_class (keys %augment_map) {
				next
					if current->isa (PPIx::Augment::Element::)
					;

				next
					unless current->isa ($ppi_class)
					;

				...;
				last;
			}
		};
};

1;

