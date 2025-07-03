#!/usr/bin/env perl

use v5.14;
use strict;

package App::config {
	use Path::Tiny;
	use Ref::Util;

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

	sub new {
		my ($class) = @_;

		my $self = bless { }, $class;

		$self->{config} = $self->load_config_file;

		return $self;
	}

	sub config {
		my ($self, $policy, $key) = @_;

		return $self->{config}
			&& exists $self->{config}{$policy}
			&& $self->{config}{$policy}{$key}
			;
	}

	sub load_config_file {
		my ($self) = @_;

		return
			unless my $file = $self->search_config_file;

		my $current  = { };
		my %sections = ( q () => $current );

		my @lines = $file->lines_utf8;
		while (@lines) {
			my $line = shift @lines;
			chomp $line;

			if (my ($policy, $key) = $line =~ $re_section) {
				my $section = join (q ( / ) => grep { defined && length } $policy, $key);
				$current = $sections{$section} //= {
					policy    => $policy,
					section   => $section,
					default   => 0,
					include   => [ ],
					exclude   => [ ],
					__options => { },
				};

				# trace { qq ([config] $current->{section}) };
				next;
			}

			if (my ($property, $value) = $line =~ $re_property) {
				if (exists $current->{$property}) {
					# trace { qq ([config] $current->{section} => $property = $value) };
					Ref::Util::is_arrayref ($current->{$property})
						? ( push @{ $current->{$property} }, $value )
						: ( $current->{$property} = $value )
						;
					next;
				}

					# trace { qq ([config] $current->{section} => option $property = $value) };
				my $options = $current->{__options} //= { };

				unless (exists $options->{$property}) {
					$options->{$property} = $value;
					next;
				}

				unless (Ref::Util::is_arrayref ($options->{$property})) {
					$options->{$property} = [ $options->{$property}, $value ];
					next;
				}

				push @{ $options->{$property} }, $value;

				next;
			}
		}

		return \ %sections;
	}

	sub option {
		my ($self, $policy, $key) = @_;

		return $self->{config}
			&& exists $self->{config}{$policy}
			&& $self->{config}{$policy}{__options}{$key}
			;
	}

	sub search_config_file {
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
}

package App::ppi_sanity {
	use Attribute::Handlers;
	use List::Util;
	use POSIX qw (strftime);
	use Term::ANSIColor qw ();

	my %POLICIES_ALL;

	sub Default                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};

		$POLICIES_ALL{$name}{default} = 1;
	}

	sub Policy                          :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};

		$POLICIES_ALL{$name}{name}    = $name;
		$POLICIES_ALL{$name}{handler} = $referent;
		$POLICIES_ALL{$name}{key}     = $name =~ s (^policy_) ()r =~ tr [_] [-]r,
	}

	my $color_theme = {
		ERROR => q (red),
		WARN  => q (magenta),
		INFO  => undef,
		DONE  => q (green),
		TRACE => q (cyan),
	};

	my $log_use_color = -t STDOUT;
	my $log_verbose   = 0;
	my $log_with_time = 1;

	sub log_done (&);
	sub log_error (&);
	sub log_info (&);
	sub log_verbose (&);
	sub log_warning (&);

	sub _colored {
		my ($semantic_color, @what) = @_;

		return @what
			unless $log_use_color
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

	sub log_done (&) {
		_log DONE => @_;
	}

	sub log_error (&) {
		_log ERROR => @_;
	}

	sub log_info (&) {
		_log INFO => @_;
	}

	sub log_verbose (&) {
		_log TRACE => @_
			if $log_verbose
			;
	}

	sub log_warning (&) {
		_log WARN => @_;
	}

	sub run {
		return 0;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;
