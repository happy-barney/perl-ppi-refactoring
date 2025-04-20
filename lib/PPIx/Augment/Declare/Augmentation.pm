
use v5.14;
use warnings;

package PPIx::Augment::Declare::Augmentation {
	use PPIx::Augment::Internals::Exporter;

	use mro;

	use Safe::Isa qw ($_isa);
	use Sub::Util qw (set_subname);

	require PPIx::Augment::Utils;
	require PPIx::Augment::Internals;
	require PPIx::Augment::Augmentation;

	use namespace::clean;

	our %augmentations;

	sub _exporter_validate_opts {
		my ($class, $globals) = @_;

		PPIx::Augment::Augmentation::->PPIx::Augment::Internals::ensure_isa ($globals->{into});

		return 1;
	}

	sub _generate_how_to_augment :Exported {
		my ($class, $name, $args, $globals) = @_;
		my $caller = $globals->{into};

		return set_subname
			qq (${caller}::${name}),
			sub { $augmentations{$caller}{invoke} }
			;
	}

	sub _generate_what_to_augment :Exported {
		my ($class, $name, $args, $globals) = @_;
		my $caller = $globals->{into};

		return set_subname
			qq (${caller}::${name}),
			sub { $augmentations{$caller}{where} }
			;
	}

	sub declare :Exported {
		shift; # string 'augmentation'

		my $name = ref $_[0] ? q () : shift;

		my @where  = grep { $_->$_isa (PPIx::Augment::Utils::CLASS_WHERE) } @_;
		my @invoke = grep { $_->$_isa (PPIx::Augment::Utils::CLASS_INVOKE) } @_;

		die <<'USAGE'
Usage: declare augmentation => [optional name]
    => where { }
    => invoke { }
USAGE
			unless @where && @invoke
			;

		my $caller = caller;

		$augmentations{$caller}{invoke}{$name} = \ @invoke;
		$augmentations{$caller}{where}{$name}  = \ @where;
	}

	1;
}
