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
	use PPI;
	use Path::Iterator::Rule;

	BEGIN {
		App::ppi_sanity::attributes->import;
		App::ppi_sanity::config::->import;
		App::ppi_sanity::logger::->import;
	}

	my @DEFAULT_INCLUDE = qw (bin lib t);
	my $dry_run       = 0;

	sub invoke (&;@);
	sub where (&;@);

	sub _build_path_lookup {
		return
			unless my @parts = grep { $_ } @_
			;

		my $parts = join q (|) => map { qr ((?:$_)) } grep { $_ } @parts;

		return qr ((?:$parts)$);
	}

	sub _build_policies {
		my ($config, $default, @policy_options) = @_;

		my @policies = _effective_policies ($config, @policy_options);
		my %options  = map { ($_->{policy} => $_) } @policy_options;

		return
			map {
				my $policy  = $_;
				my $handler = _policy_handler ($_);

				map {
					my $section = $config->{config}{$_};
					+{
						policy    => $policy,
						section   => $_,
						handler   => $handler,
						options   => $section->{_options},
						qualifies => _build_policy_qualifier ($_, $config, $default, $options{$policy}),
					}
				} $config->policy_sections ($policy)
			}
			@policies
			;
	}

	sub _build_policy_qualifier {
		my ($policy, $config, $default, @options) = @_;

		my @policy_option = grep { $_->{policy} eq $policy } @options;

		my $with    = _build_path_lookup (map { $_->{with}    } $default, @policy_option);
		my $without = _build_path_lookup (map { $_->{without} } $default, @policy_option);

		my $policy_include  = _build_path_lookup (@{ $policy_option[0]->{include} // [] });
		my $policy_exclude  = _build_path_lookup (@{ $policy_option[0]->{exclude} // [] });

		my $default_include = _build_path_lookup (@{ $default->{include} // [] });
		my $default_exclude = _build_path_lookup (@{ $default->{exclude} // [] });

		my $config_include  = _build_path_lookup (@{ $config->config ($policy => q (include)) // []});
		my $config_exclude  = _build_path_lookup (@{ $config->config ($policy => q (exclude)) // []});

		my $global_include  = _build_path_lookup (@{ $config->config (q () => q (include)) // []});
		my $global_exclude  = _build_path_lookup (@{ $config->config (q () => q (exclude)) // []});

		return sub {
			my ($path) = @_;

			return 1 if $with            && $path =~ $with;
			return 0 if $without         && $path =~ $without;

			return 1 if $policy_include  && $path =~ $policy_include;
			return 0 if $policy_exclude  && $path =~ $policy_exclude;

			return 1 if $default_include && $path =~ $default_include;
			return 0 if $default_exclude && $path =~ $default_exclude;

			return 1 if $config_include  && $path =~ $config_include;
			return 0 if $config_exclude  && $path =~ $config_exclude;

			return 1 if $global_include  && $path =~ $global_include;
			return 0 if $global_exclude  && $path =~ $global_exclude;

			return 0 if $policy_include || $default_include || $config_include || $global_include;
			return 1 if $policy_exclude || $default_exclude || $config_exclude || $global_exclude;

			return 0;
		}
	}

	sub _current {
		$_;
	}

	sub _element {
		return shift
			if Scalar::Util::blessed ($_[0])
			&& $_[0]->isa (q (PPI::Element))
			;

		return $_;
	}

	sub _effective_policies {
		my ($config, @options) = @_;

		my @policies = @options
			? map { $_->{policy} } @options
			: $config->default_policies
			;

		@policies = policy_list_default
			unless @policies
			;

		return @policies;
	}

	sub _includes_from_options {
		my @include =
			grep { -e $_ }
			map  { @{ $_ // [] } }
			map { $_->{include}, $_->{with} }
			@_
			;

		@include = @DEFAULT_INCLUDE
			unless @include
			;

		return @include;
	}

	sub _is {
		my ($value, @classifications) = @_;

		my @queue = ([ $value => \ @classifications ]);

		while (@queue) {
			my ($value, $condition) = @{ shift @queue };

			return 0
				unless defined $value
				;

			next
				unless defined $condition
				;

			if (Ref::Util::is_arrayref ($condition)) {
				unshift @queue, map { +[ $value => $_ ] } @$condition;
				next;
			}

			if (Ref::Util::is_hashref ($condition)) {
				return 0
					unless Scalar::Util::blessed ($value)
					;

				for my $method (keys %$condition) {
					my $sub_condition = $condition->{$method};

					$value->isa ($sub_condition) ? next : return 0
						if $method eq q (isa)
						;

					unshift @queue, [ $value->$method => $sub_condition ];
				}

				next;
			}

			$value =~ $condition ? next : return 0
				if Ref::Util::is_regexpref ($condition)
				;

			$condition->($value) ? next : return 0
				if Ref::Util::is_coderef ($condition)
				;

			$value eq $condition ? next : return 0;
		}

		return 1;
	}

	sub _is_quote_double {
		local $_ = &_element;

		_is $_, { isa => PPI::Token::Quote::Double:: }, @_;
	}

	sub _is_quote_single {
		local $_ = &_element;

		_is $_, { isa => PPI::Token::Quote::Single:: }, @_;
	}

	sub _path_iterator {
		return Path::Iterator::Rule
			->new
			->not_name (q (.git))
			->skip_dir (q (.git))
			->file
			->or (
				Path::Iterator::Rule->new->name (qr ( [.] (?: pm | pl | t ) $ )x),
				Path::Iterator::Rule->new->shebang (qr (^[#]! .* \b perl \b )x),
			)
			->iter (@_, { recurse => 1 })
			;
	}

	sub _policy_handler {
		my ($key) = @_;

		for my $policy (values %POLICIES_ALL) {
			return $policy->{handler}
				if $key eq $policy->{name}
				|| $key eq $policy->{key}
				;
		}

		return;
	}

	sub _ppi_document {
		my ($path, %options) = @_;

		my $document = PPI::Document::->new (qq ($path));
		$document->tab_width (4);

		return $document;
	}

	sub invoke (&;@) {
		my ($code, @rest) = @_;

		return (
			sub { local $_ = $_[1]; $code->(@_) },
			@rest,
		);
	}

	sub ppix_search {
		local $_ = &_element;
		my ($where) = @_;

		@{ $_->find ($where) || [] };
	}

	sub ppix_replace {
		my ($element, $where, $invoke) = (&_element, @_);

		for my $found (ppix_search $element, $where) {
			$found->insert_before ($invoke->($found));
			$found->remove;
		}
	}

	sub where (&;@) {
		my ($code, @rest) = @_;

		return (
			sub { local $_ = $_[1]; $code->(@_) },
			@rest,
		);
	}

	sub parse_options {
		my (@argv) = @_;

		my @options = (my $current = { });

		my $parser = Getopt::Long::Parser->new (
			config => [qw [require_order]],
		);

		my %policies;

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
					unless my $policy_key = policy_search ($policy)
					;

				unless (($current = $policies{$policy_key})) {
					push @options, $current = $policies{$policy_key} = { policy => $policy_key };
				}
			}
		}

		return @options;
	}

	sub policy_replace_quotes                   :Policy {
		local $_ = &_element;

		ppix_replace
			where  { _is_quote_double },
			invoke { _current->set_content (qq (qq (${\ _current->string }))) }
			;

		ppix_replace
			where  { _is_quote_single },
			invoke { _current->set_content (qq (q (${\ _current->string }))) }
			;
	}

	sub run {
		my $config = App::config->new;
		my @options = parse_options (@_);

		$log_verbose = $options[0]{verbose};
		$dry_run     = $options[0]{dry_run};

		my $iterator = _path_iterator (_includes_from_options (@options));
		my @policies = _build_policies ($config, @options);

		my $exit_value = 0;
		while (my $path = $iterator->()) {
			verbose { qq (process file $path) };

			my $changes = 0;
			my $document;

			for my $policy (@policies) {
				verbose { qq (qualify policy $policy->{key}) };

				next
					unless $policy->{qualifies}->($path)
					;

				$document //= _ppi_document ($path);

				verbose { qq (Apply '$policy->{key}' to $path) };

				if (my $count = $policy->{handler}->($document)) {
					info { qq (Applied '$policy->{key}' $count time(s) to $path) };
					$changes += $count;
				}
			}

			if ($changes) {
				$exit_value = 1;
				$document->save ($path)
					unless $dry_run
					;
			}
		}

		return $exit_value;
	}
}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;

1;
