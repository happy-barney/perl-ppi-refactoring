#!/usr/bin/env perl

use v5.14;
use warnings;

package App::ppi_sanity::attributes {
	use Exporter q (import);

	use Attribute::Handlers;

	BEGIN {
		our @EXPORT = (
			q (policy_apply),
			q (policy_list),
			q (policy_list_default),
			q (policy_search),
		);
	}

	my %POLICIES;

	sub _normalise_policy_name ($);

	sub Default                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $key = _normalise_policy_name *{$symbol}{NAME};

		$POLICIES{$key}{default} = 1;
	}

	sub Policy                          :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};
		my $key = _normalise_policy_name $name;

		$POLICIES{$key}{name}    = $name;
		$POLICIES{$key}{handler} = $referent;
		$POLICIES{$key}{key}     = $key;
	}

	sub _build_character_lookup_regex {
		my $regex = join q (.*-) => split q (), shift;

		return qr (^$regex);
	}

	sub _build_component_lookup_regex {
		my $regex = join q (.*-) => split q (-), shift;

		return qr (^$regex);
	}

	sub _normalise_policy_name ($) {
		lc shift
			=~ s (^policy_) ()r
			=~ tr [_] [-]r
	}

	sub policy_apply {
		my $name = shift;

		return
			unless my $spec = $POLICIES{$name}
			;

		$spec->{handler}->(@_);
	}

	sub policy_list {
		return sort keys %POLICIES;
	}

	sub policy_list_default {
		return sort grep { $_->{default} } keys %POLICIES;
	}

	sub policy_search {
		my $name = _normalise_policy_name (shift);

		return $name
			if exists $POLICIES{$name}
			;

		for my $regex (
			_build_component_lookup_regex ($name),
			_build_character_lookup_regex ($name),
		) {
			my @matches = grep { $_ =~ $regex } keys %POLICIES;

			return $matches[0]
				if @matches == 1
				;
		}

		return undef;
	}

	1;
}

package App::ppi_sanity::config {
	use Exporter q (import);

	use Path::Tiny;
	use Ref::Util;

	BEGIN {
		our @EXPORT = (
			q (config),
		);
	}

	my $re_section  = qr (
		^
		\s* \[
		\s* ( [^/\]]+) (?<= \S)
		(?:
			\s* /
			\s* ( [^/\]]+) (?<= \S)
		)*
		\s* \]
	)x;

	my $re_property = qr (
		^
		\s* ((?&property_name))
		\s* [=]
		\s* ((?&property_value))

		(?(DEFINE)
			(?<value_quoted>
				(?<quote> ['"] )
				(?: (?: \\.)+ | (?: (?! \g{quote} ) [^\\] )+ )*
				\g{quote}
			)

			(?<value_unquoted> (?= \S) [^;#]+ (?<= \S))

			(?<property_name> (?= \S) [^;#=]+ (?<= \S))

			(?<property_value> (?&value_quoted) | (?&value_unquoted))
        )
	)x;

	sub _config_file_load;
	sub _config_file_search;

	sub config {
		state $config = bless { coonfig => _config_file_load };
	}

	sub _accessor {
		my ($self, @path) = @_;

		my $current = $self;
		for my $key (@path) {
			return
				unless defined $current->{$key}
				;

			$current = $current->{$key};
		}

		return $current;
	}

	sub _config_file_load {
		return
			unless my $file = _config_file_search
			;

		my $current  = { };
		my %sections = ( q () => $current );

		my @lines = $file->lines_utf8;
		while (@lines) {
			my $line = shift @lines;
			chomp $line;

			if (my ($policy, $key) = $line =~ $re_section) {
				my $section = join (q ( / ) => grep { defined && length } $policy, $key);

				$current = $sections{$section} //= {
					policy  => $policy,
					section => $section,
					default => 0,
					include => [ ],
					exclude => [ ],
					_       => { },
				};

				next;
			}

			if (my ($property, $value) = $line =~ $re_property) {
				if (exists $current->{$property}) {
					Ref::Util::is_arrayref ($current->{$property})
						? ( push @{ $current->{$property} }, $value )
						: ( $current->{$property} = $value )
						;
					next;
				}

				my $properties = $current->{_};

				unless (exists $properties->{$property}) {
					$properties->{$property} = $value;
					next;
				}

				unless (Ref::Util::is_arrayref ($properties->{$property})) {
					$properties->{$property} = [ $properties->{$property}, $value ];
					next;
				}

				push @{ $properties->{$property} }, $value;

				next;
			}
		}

		return \ %sections;
	}

	sub _config_file_search {
		my $path = Path::Tiny::cwd;

		until ($path->is_rootdir) {
			my $candidate = $path->child (q (.ppi-sanity.ini));
			return $candidate
				if $candidate->is_file
				&& $candidate->exists
				;
			$path = $path->parent;
		}

		return;
	}

	sub default_policies {
		my ($self) = @_;

		my %uniq =
			map  { $_->{policy} => 1 }
			grep { $_->{default} }
			values %{ $self->{config} // +{ } }
			;

		return keys %uniq;
	}

	sub policy_sections {
		my ($self, $policy) = @_;

		my $config = $self->{config} // { };

		return
			grep { $_->{policy} eq $policy }
			grep { $_ }
			values %$config
			;
	}

	sub section_config {
		my ($self, $section, $key) = @_;

		return $self->_accessor (config => $section => $key);
	}

	sub section_property {
		my ($self, $section, $key) = @_;

		return $self->_accessor (config => _ => $section => $key);
	}

	sub set_default_section_config {
		my ($self, $section, $key, $value) = @_;

		$self->{config}{$section}{$key} //= $value;
	}

	sub set_default_section_property {
		my ($self, $section, $key, $value) = @_;

		$self->{config}{$section}{_}{$key} //= $value;
	}

	1;
}

package App::ppi_sanity::logger {
	use Exporter q (import);

	use List::Util;
	use POSIX qw (strftime);
	use Term::ANSIColor qw ();

	BEGIN {
		our @EXPORT = (
			q (log_done),
			q (log_error),
			q (log_info),
			q (log_verbose),
			q (log_warning),
		);
	}

	my $color_theme = {
		ERROR => q (red),
		WARN  => q (magenta),
		INFO  => undef,
		DONE  => q (green),
		TRACE => q (cyan),
	};

	my $log_use_colours = -t STDOUT;
	my $log_verbose     = 0;
	my $log_with_time   = 1;

	sub _colored {
		my ($semantic_color, @what) = @_;

		return @what
			unless $log_use_colours
			&& (my $color = $color_theme->{$semantic_color})
			;

		return Term::ANSIColor::colored ([ $color ], @what);
	}

	sub _log {
		my ($level, $code) = @_;

		return
			unless my @message = $code->()
			;

		state $length = List::Util::max (map { length } keys %$color_theme);

		local $, = q ( );
		say
			$log_with_time ? strftime (q ([%T]), localtime) : (),
			_colored ($level, sprintf q (%-*s), $length, $level),
			@message
			;
	}

	sub log_done (&)    { _log DONE  => @_ }
	sub log_error (&)   { _log ERROR => @_ }
	sub log_info (&)    { _log INFO  => @_ }
	sub log_verbose (&) { _log TRACE => @_ if $log_verbose }
	sub log_warning (&) { _log WARN  => @_ }
	sub set_use_colours { $log_use_colours = shift }
	sub set_verbosity   { $log_verbose     = shift }
	sub set_with_time   { $log_with_time   = shift }

	1;
}

package App::ppi_sanity {
	use Getopt::Long qw (GetOptionsFromArray);

	BEGIN {
		App::ppi_sanity::attributes->import;
		App::ppi_sanity::config::->import;
		App::ppi_sanity::logger::->import;
	}

	sub parse_options {
		my (@argv) = @_;

		my @options = (my $current = { });

		my $parser = Getopt::Long::Parser->new (
			config => [qw [require_order]],
		);

		while (@argv) {
			$parser->getoptionsfromarray (
				\ @argv,
				$current,
				'include=s@',
				'exclude=s@',
				'verbose',
				'with=s@',
				'without=s@',
			);

			while (my $policy = shift @argv) {
				die qq (Unknown policy '$policy')
					unless policy_search ($policy)
					;

				push @options, $current = { policy => $policy_key };
			}
		}

		return @options;
	}

	sub run {
		my $config = App::config->new;
		my @options = parse_options (@_);

		return 0;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;

1;
