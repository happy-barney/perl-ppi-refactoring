
use v5.14;
use warnings;

package PPIx::Augment::Utils::Exporter {
	use parent q (Exporter::Tiny);

	use Attribute::Handlers;
	use Ref::Util qw ();

	my %where;

	sub _export_code {
		my ($package, $symbol, $where, @tags) = @_;

		no strict q (refs);

		my $lookup = $where{$package} //= _register_package ($package);
		my $name   = *{$symbol}{NAME};

		push @{ $lookup->{$where} }, $name;
		unshift @tags, q (all);
		unshift @tags, q (default)
			if $where eq q (EXPORT)
			;

		my %seen;
		while (my $tag = shift @tags) {
			push @tags, @$tag
				and next
				if Ref::Util::is_arrayref ($tag)
				;

			next
				if exists $seen{$tag}
				;

			$seen{$tag} = push @{ $lookup->{EXPORT_TAGS}{$tag} //= [] }, $name;
		}
	}

	# Reimplementing of Exporter::Attributes as far as it doesn't work with Exporter::Tiny
	sub _register_package {
		my ($package) = @_;
		no strict q (refs);

		return +{
			EXPORT      => \ @{ qq (${package}::EXPORT) },
			EXPORT_OK   => \ @{ qq (${package}::EXPORT_OK) },
			EXPORT_TAGS => \ %{ qq (${package}::EXPORT_TAGS) },
		};
	}

	sub import {
		my ($package) = @_;
		my $caller = caller;

		no strict q (refs);

		my $isa = \ @{ qq (${caller}::ISA) };
		push @$isa, $package
			unless grep { $_ eq $package } @$isa
			;

		goto &Exporter::Tiny::import;
	}

	sub Exportable :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		_export_code ($package, $symbol, q (EXPORT_OK), $data);
	}

	sub Exported :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		_export_code ($package, $symbol, q (EXPORT), $data);
	}

	1;
}

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Utils::Exporter

=head1 SYNOPSIS

    package My::Package;
    use parent q (PPIx::Augment::Utils::Exporter);

    sub foo :Exported ...
    sub bar :Exportable(tag1) ...
    sub baz :Exportable(tag1,tag2) ...

=head1 DESCRIPTION

Minimalistic glue allowing to declare export behaviour via attributes
instead of maintaining C<@EXPORT>, C<@EXPORT_OK>, C<%EXPORT_TAGS>

Covers C<PPIx::Augment::Utils> needs.

Default tags:

=over

=item all

Contains every exported symbol.

=item default

Contains every C<Exported> symbol

=back

=head1 ATTRIBUTES

=head2 Exported(tags)

Symbol marked with this atribute is put into C<@EXPORT>
and every specified tag (including C<all>, C<default>).

=head2 Expotable(tags)

Symbol marked with this atribute is put into C<@EXPORT_OK>
and every specified tag (including C<all>).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut

