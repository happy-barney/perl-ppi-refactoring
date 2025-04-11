
use v5.14;
use warnings;

package PPIx::Augment::Internals::Exporter {
	use parent q (Exporter::Tiny);

	use Attribute::Handlers;

	use PPIx::Augment::Internals qw (
		flatten_array
		push_unique_string
	);

	sub _export_code;

	use namespace::clean;

	my %attributes = (
		Exported   => { EXPORT    => [qw [all default]] },
		Exportable => { EXPORT_OK => [qw [all        ]] },
	);

	sub import {
		my ($package) = @_;
		my $caller = caller;

		# consumer's import
		goto &Exporter::Tiny::import
			unless $package eq __PACKAGE__
			;

		# our import
		__PACKAGE__->PPIx::Augment::Internals::ensure_isa ($caller);

		();
	}

	sub _export_code {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};
		my ($where, $implicit_tags) = %{ $attributes{$attr} };

		$name =~ s (^ _generate_ ) ()x;

		no strict q (refs);
		push_unique_string @{ qq (${package}::${where})}, $name;
		push_unique_string @{ qq (${package}::EXPORT_OK)}, $name;

		push_unique_string @{ ${qq (${package}::EXPORT_TAGS)}{$_} //= [] }, $name
			for
			grep { defined }
			flatten_array $data, $implicit_tags
			;
	}

	sub Exportable                      :ATTR(CODE,BEGIN) {
		&_export_code;
	}

	sub Exported                        :ATTR(CODE,BEGIN) {
		&_export_code;
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Internals::Exporter

=head1 SYNOPSIS

    package My::Package;
    use parent q (PPIx::Augment::Internals::Exporter);

    sub foo :Exported ...
    sub bar :Exportable(tag1) ...
    sub baz :Exportable(foo,bar) ...

=head1 DESCRIPTION

Minimalistic glue allowing to one declare export behaviour via sub attributes
instead of maintaining C<@EXPORT>, C<@EXPORT_OK>, C<%EXPORT_TAGS> by hand.

The primary motivation is to type the exported symbol name only once.

Symbols are then exported using C<Exporter::Tiny>.

Default tags:

=over

=item all

Contains every symbol.

=item default

Contains every C<Exported> symbol

=back

=head1 ATTRIBUTES

=head2 Exported(tags)

Exports the symbol it is used on by default.

Examples:

=over

=item export symbol by default

    sub exported_by_default   :Exported { ... };

Behaves like the following

    our @EXPORT      = qw (exported_by_default);
    our %EXPORT_TAGS = (
        all     => [qw[ exported_by_default ]],
        default => [qw[ exported_by_default ]],
    );

=item export symbol by default with additional tags

    sub exported_by_default_with_tags :Exported(v0, v1) { ... };

Behaves like the following

    our @EXPORT      = qw (exported_by_default_with_tags);
    our %EXPORT_TAGS = (
        all     => [qw[ exported_by_default_with_tags ]],
        default => [qw[ exported_by_default_with_tags ]],
        v0      => [qw[ exported_by_default_with_tags ]],
        v1      => [qw[ exported_by_default_with_tags ]],
    );

=back

=head2 Exportable(tags)

Exports the symbol it is used on demand.

Examples:

=over

=item export symbol on demand

    sub exported_on_demand   :Exportable { ... };

Behaves like following

    our @EXPORT_OK   = qw (exported_on_demand);
    our %EXPORT_TAGS = (
        all     => [qw[ exported_on_demand ]],
    );

=item export symbol on demand with additional tags

    sub exported_on_demand_with_tags :Exportable(v0, v1) { ... };

Behaves like following

    our @EXPORT_OK   = qw (exported_on_demand_with_tags);
    our %EXPORT_TAGS = (
        all => [qw[ exported_on_demand_with_tags ]],
        v0  => [qw[ exported_on_demand_with_tags ]],
        v1  => [qw[ exported_on_demand_with_tags ]],
    );

=back

=head1 SEE ALSO

=over

=item L<Exporter::Tiny>

=item L<Exporter::Attributes>

Similar approach but (at the time of writing this) doesn't work with L<Exporter::Tiny>.

=back

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of the L<PPIx::Augment> distribution.
It may be modified and/or distributed under the same terms as the distribution itself.

=cut
