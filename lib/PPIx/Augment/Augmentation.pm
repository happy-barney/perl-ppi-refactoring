
use v5.14;
use warnings;

package PPIx::Augment::Augmentation {

	use PPIx::Augment::Tools::Exporter;

	require PPIx::Augment::Utils;
	require PPIx::Augment::Tools;
	require PPIx::Augment::Augmentation::Base;

	sub declare :Exported {
		my $caller = caller;

		my $what = shift;
		my $name = ref $_[0] ? undef : shift;

		my $where  = &PPIx::Augment::Utils::_build_args_where;
		my $invoke = &PPIx::Augment::Utils::_build_args_invoke;

		$caller->_register_augmentation ($name, $where, $invoke);

		1;
	}

	sub import {
		my ($package) = @_;
		my $caller = ;

		$package->PPIx::Augment::Tools::setup_isa (PPIx::Augment::Augmentation::Base::);
		goto &Exporter::Tiny::import;
		

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


	1;
}
