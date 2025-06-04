#!/usr/bin/env perl

use v5.14;
use warnings;

use utf8;


use PPI;

sub dist_ini;
sub dist_module;
sub dist_root;

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

sub license_text {
	my ($module) = @_;

	return $module eq dist_module
		? _distribution_module_license_text
		: _component_module_license_text ($module)
		;
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
