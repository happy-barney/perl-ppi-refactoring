#!/usr/bin/env perl

use v5.14;
use warnings;

use utf8;

use Module::Find;
use Module::Load;
use Path::Tiny;

use PPI;

sub _distribution_root;
sub _distribution_name;
sub _initialize_isa;
sub _list_augmented_classes;
sub _list_classes;
sub _list_isa;
sub _list_ppi_classes;
sub _search_classes;
sub dist_ini;
sub dist_module;
sub dist_root;

my %isa;

sub _augmented_class {
	my ($ppi_class) = @_;

	$ppi_class =~ s ( ^ PPI:: ) (PPIx::Augment::DOM::)xr;
}

sub _augmented_package_template {
	my ($package_name) = @_;
	my $package_isa = join qq (\n) => map { qq (\t\t$_) } _list_isa ($package_name);

	my $template = <<'TEMPLATE';

use v5.14;
use warnings;

package <package-name> {
	use parent qw (
<ackage-isa>
	);

	use mro q (c3);

	use PPI v1.278;

	1;
};

__END__
=pod

=encoding utf-8

=cut
TEMPLATE

	return $template
		=~ s (<package-name>) ($package_name)r
		=~ s (<package-isa>)  ($package_isa)r
		;
}

sub _component_module_license_text {
	my $license_text = <<"END_OF_COMPONENT_LICENSE";
This module is part of the L<${\ (dist_module)}> distribution.
It may be modified and distributed under the same terms as the distribution itself.
END_OF_COMPONENT_LICENSE

	chomp ($license_text);
	return $license_text;
}

sub _distribution_module_license_text {
}

sub _is {
	my ($element, $class) = @_;

	return $element->isa ($class);
}

sub _is_token {
	my ($element, $class, $regex) = @_;

	$regex = qr (^\Q$regex\E$)
		if defined $regex
		&& ! ref $regex
		;

	return 0 unless _is ($element, $class);
	return 0 unless ! $regex || $element =~ $regex;
	return 1;
}

sub _is_token_pod {
	my ($element, $regex) = @_;

	_is_token ($element, q (PPI::Token::Pod), $regex);
}

sub _ppi_search {
	my ($document, $where) = @_;

	@{ $document->find ($where) || [] };
}

sub _where (&;@) {
	my ($code, @rest) = @_;

	return (
		sub { local $_ = $_[1]; $code->(@_) },
		@rest,
	);
}

sub ensure_license_text {
	my ($document, $module) = @_;

	my @pod = _ppi_search $document, _where { _is_token_pod  };

	unless (@pod) {
		my ($end) = _ppi_search $document, where { _is q (PPI::Statement::End) };

		$end
	qr (^=head1 COPYRIGHT AND LICENSE)ms };
	my ($pod) = _search_pod $document, qr (^=head1 COPYRIGHT )AND LICENSE)ms;
	$pod //= _build_li
}

sub _is_augmented_class {
	my ($class) = @_;

	$class =~ qr (^ PPIx ::)x;
}

sub _initialize_augmented_classes {
	for my $ppi_class (_list_ppi_classes) {
		my $augmented_class = _augmented_class $ppi_class;

		$isa{$augmented_class} //= [
			(map { _augmented_class $_ } _list_isa $ppi_class),
			 $ppi_class,
		];
	}

	grep { _is_augmented_class $_ } _list_classes;
}

sub license_text {
	my ($module) = @_;

	return $module eq dist_module
		? _distribution_module_license_text
		: _component_module_license_text ($module)
		;
}

sub _list_isa {
	my ($class) = @_;

	$isa{$class} //= do {
		no strict q (refs);

		[ grep { exists $isa{$_} } @{"${class}::ISA"} ];
	};

	return @{ $isa{$class} };
}

sub _list_classes {
	return
		map  { $isa{$_} //= undef; $_ }
		grep { ! $_->isa (PPI::Document::) }
		grep { $_->isa (PPI::Element::) }
		Module::Find::findallmod (q (PPI)),
		Module::Find::findallmod (q (PPIx::Augment::DOM))
		;
}

sub _list_ppi_classes {
	grep { ! _is_augmented_class $_ } _list_classes;
}

sub _package_path {
	my ($package_name) = @_;

	return Path::Tiny::->new (__FILE__)
		->parent (2)
		->child (q (lib))
		->child (split qr (::), $package_name . q (.pm))
		;
}

sub augmented_package_document {
	my ($package_name) = @_;

	my $path = _package_path ($package_name);

	my $source = $path->exists
		? $path->stringify
		: \ _augmented_package_template ($package_name)
		;

	my $document = PPI::Document::->new ($source);
	$document->tab_width (4);

	return $document;
}

sub dist_ini {
	state $dist_ini = do {
		require Config::INI::Reader;
		Config::INI::Reader->read_file (
			dist_root->child (q (dist.ini))
		);
	};
}

sub dist_root {
	state $dist_root = do {
		require Path::Tiny;
		my $pwd = Path::Tiny::->cwd;

		while (1) {
			$pwd = undef
				if $pwd eq $pwd->rootdir
				;

			last
				if ! defined $pwd
				|| $pwd->child (q (.git))->exists
				|| $pwd->child (q (dist.ini))->exists
				;

			$pwd = $pwd->parent;
		}

		$pwd;
	};
}

sub dist_module {
	state $dist_module = do {
		dist_ini->{_}{name} =~ s ([-]) (::)gr;
	};
}

say license_text (q (PPIxx::Augment::DOM::Element));
say dist_package;

for my $class (_list_ppi_classes) {
	say $class;
	say q (  - ), $_ for _list_isa $class;
}

