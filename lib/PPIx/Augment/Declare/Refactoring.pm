
use v5.14;
use warnings;

package PPIx::Augment::Declare::Refactoring {
	use PPIx::Augment::Internals::Exporter;

	use mro;

	use Safe::Isa qw ($_isa);
	use Sub::Util qw (set_subname);

	require PPIx::Augment::Utils;
	require PPIx::Augment::Internals;
	require PPIx::Augment::Augmentation;

	use namespace::clean;

	our %refactorings;

	sub _generate_how_to_refactor :Exported {
		my ($class, $name, $args, $globals) = @_;
		my $caller = $globals->{into};

		return set_subname
			qq (${caller}::${name}),
			sub { $refactorings{$caller}{invoke} }
			;
	}

	sub _generate_what_to_refactor :Exported {
		my ($class, $name, $args, $globals) = @_;
		my $caller = $globals->{into};

		return set_subname
			qq (${caller}::${name}),
			sub { $refactorings{$caller}{where} }
			;
	}

	sub _exporter_validate_opts {
		my ($class, $globals) = @_;

		my $base_class = $globals->{-isa} // PPIx::Augment::Refactoring::;

		PPIx::Augment::Internals::ensure_isa ($base_class, $globals->{into});

		return 1;
	}

	sub declare :Exported {
		shift; # string 'augmentation'

		my $name = ref $_[0] ? q () : shift;

		my @where  = grep { $_->$_isa (PPIx::Augment::Utils::CLASS_WHERE) } @_;
		my @invoke = grep { $_->$_isa (PPIx::Augment::Utils::CLASS_INVOKE) } @_;

		die <<'USAGE'
Usage: declare refactoring => [optional name]
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

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Declare::Refactoring - Helper to declare refactorings

=head1 SYNOPSIS

	package My::Refactoring;

	use PPIx::Augment::Declare::Refactoring;

	declare refactoring
		=> where { ... }
		=> invoke { ... }
		;

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
