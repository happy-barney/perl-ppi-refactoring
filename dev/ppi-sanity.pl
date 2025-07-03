#!/usr/bin/env perl

use v5.14;
use warnings;

package App::ppi_sanity::attributes {
	use Exporter q (import);

	use Attribute::Handlers;
	use List::Util;
	use POSIX qw (strftime);
	use Term::ANSIColor qw ();

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
	use Path::Iterator::Rule;
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
	use Path::Tiny;
	use Ref::Util;

	use constant ALIGN_EXPORT_BASE_COLUMN => 40;

	BEGIN {
		App::ppi_sanity::attributes->import;
		App::ppi_sanity::config::->import;
		App::ppi_sanity::logger::->import;
	}

	my @DEFAULT_INCLUDE = qw (bin lib t);

	my @DEFAULT_INCLUDE = qw (bin lib t);

	sub dist_ini;
	sub dist_module;
	sub dist_root;
	sub where (&;@);
	sub invoke (&;@);

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

	my $dry_run       = 0;

	sub log_done (&);
	sub log_error (&);
	sub log_info (&);
	sub log_verbose (&);
	sub log_warning (&);

	sub _build_path_iterator {
		my ($options) = @_;

		my $exclude = _build_path_regex (@{ $options->{exclude} // [] });

		my $rule = Path::Iterator::Rule
			->new
			->file
			->or (
				Path::Iterator::Rule->new->name (qr ( [.] (?: pm | pl | t ) $ )x),
				Path::Iterator::Rule->new->shebang (qr (^[#]! .* \b perl \b )x),
			)
			;

		$rule = $rule ->not (sub { $_ =~ $exclude })
			if $exclude
			;

		$rule->iter (@{ $options->{include} }, { recurse => 1 });
	}

	sub _build_path_lookup {
		return
			unless my @parts = grep { $_ } @_
			;

		my $parts = join q (|) => map { qr ((?:$_)) } grep { $_ } @parts;

		return qr ((?:$parts)$);
	}

	sub _build_path_regex {
		return
			unless my $regex =
			join q (|),
			map {
				Ref::Util::is_regexpref ($_)
					? $_
					: join q ([/]+), map { quotemeta ($_) } split qr ([/]), $_
			}
			@_
			;

		return qr (\b $regex $)x;
	}

	sub _column {
		my ($element) = @_;
		$element->location->[2];
	}

	sub _is {
		my ($element, $class) = @_;

		return $element->isa ($class);
	}

	sub _is_sub {
		my ($element) = @_;

		return _is ($element, PPI::Statement::Sub::);
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

	sub _is_ws {
		my ($element, $regex) = @_;

		_is_token ($element, PPI::Token::Whitespace::, $regex);
	}

	sub ppi_search {
		my ($document, $where) = @_;

		@{ $document->find ($where) || [] };
	}

	sub parse_options {
		my (@argv) = @_;

		my %options = (
			verbose  => 0,
		);

		GetOptionsFromArray (
			\ @argv,
			'include=s@' => sub { push @{ $options{include} //= [] }, $_[1] },
			'exclude=s@' => sub { push @{ $options{exclude} //= [] }, $_[1] },
			'verbose'    => \ $options{verbose},

			# policies options
			map {
				my $policy = $_;
				my $option = $_ =~ tr [_] [-]r =~ s (^policy[-]) ()r;
				($option => sub { push @{ $options{policies} //= [] }, $policy })
			}
			@POLICIES
		);

		push @{ $options{include} //= [] }, @argv
			if @argv
			;

		# Default values
		# ##########################################################

		$options{include}  //= \ @DEFAULT_INCLUDE;
		$options{policies} //= \ @POLICIES;

		return \ %options;
	}

	sub policy_align_export_attributes  :Policy :Default {
		my ($document) = @_;

		my @policy_include = (
			q (lib/PPIx/Augment/Utils.pm),
			q (dev/ppi-sanity.pl),
		);

		return 0
			unless $document->filename =~ _build_path_regex (@policy_include)
			;

		my $changes = 0;
		my @operators = ppi_search $document, where {
			return 0 unless _is_token ($_, PPI::Token::Operator::, q (:));
			return 0 unless _is_sub ($_->parent);
			return 1;
		};

		for my $operator (reverse @operators) {
			my $previous_sibling = $operator->previous_sibling;
			my $has_length       = length ($previous_sibling->content);

			unless (_is_ws ($previous_sibling)) {
				$has_length = 0;
				$operator->insert_before ($previous_sibling = PPI::Token::Whitespace::->new (q ( )));
			}

			my $new_length = ALIGN_EXPORT_BASE_COLUMN - $operator->sprevious_sibling->next_sibling->visual_column_number + 1;
			$new_length = 1 if $new_length < 1;

			if ($has_length != $new_length) {
				$previous_sibling->set_content (q ( ) x $new_length);
				$changes ++;
			}
		}

		return $changes;
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

	sub _child_index {
		my ($element) = @_;
		my $children = $element->parent->{children};

		my $index = @$children;
		while ($index -- > 0) {
			return $index
				if $children->[$index] == $element
				;
		}

		return -1;
	}

	sub _cmp_sub_names {
		my ($name_a, $name_b) = @_;

		my $result = ($name_a cmp $name_b);

		return $result if $name_a =~ m (^_) or $name_b =~ m (^_);
		return -1 if $name_a eq q (new);
		return 1 if $name_b eq q (new);
		return $result;
	}

	sub _column {
		my ($element) = @_;
		$element->location->[2];
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

	sub _column {
		my ($element) = @_;
		$element->location->[2];
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
		require Software::LicenseUtils;

		my $license = eval {
			Software::LicenseUtils->new_from_short_name ({
				short_name => dist_ini->{_}{license},
				holder     => dist_ini->{_}{copyright_holder},
			})
		} // do {
			my $class = q (Software::License::) . dist_ini->{_}{license};
			Module::Load::load ($class);

			$class;
		};

		return qq (L<${\ dist_module }> is distributed under L<"${\ $license->name }"|${\ $license->url }>.)
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

	sub _is_sub {
		my ($element) = @_;

		return _is ($element, PPI::Statement::Sub::);
	}

	sub _is_sub_definition {
		my ($element) = @_;

		return 0 unless _is_sub ($element);
		return 0 unless $element->block;
		return 1;
	}

	sub _is_sub_declaration {
		my ($element) = @_;

		return 0 unless _is_sub ($element);
		return 0 if     $element->block;
		return 1;
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

	sub _is_ws {
		my ($element, $regex) = @_;

		_is_token ($element, PPI::Token::Whitespace::, $regex);
	}

	sub _path_iterator {
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

	sub _maintain_order_of_sub_declarations {
		my ($document) = @_;

		my @attributes = grep { $_->isa (PPI::Token::Attribute::) } $sub->children;

		return q () unless @attributes;
		return q () unless $attributes[0]->identifier eq q (Exported);
		return $attributes[0]->parameters;
	}

	sub _sub_classification {
		my ($sub) = @_;

		my @attributes = grep { $_->isa (PPI::Token::Attribute::) } $sub->children;

		return q () unless @attributes;
		return q () unless $attributes[0]->identifier eq q (Exported);
		return $attributes[0]->parameters;
	}

	sub _sort_subs_by_name {
		sort {
			0
				|| _sub_classification ($a) cmp _sub_classification ($b)
				|| _cmp_sub_names ($a->name, $b->name)
			}
			@_;
	}

	sub _order_subs {
		my ($document, $where) = @_;
		my @subs = ppi_search ($document, $where);

		my $changes = 0;

		my @sort =
			map { [ $_, $_->parent ] }
			_sort_subs_by_name (@subs)
			;

		@subs =
			map { [ $_, $_->parent, _child_index ($_) ] }
			@subs
			;

		my $requires_link = 0;

		my $index = @subs;
		my @tmp;
		while ($index -- > 0) {
			my $subs = $subs[$index];
			my $sort = $sort[$index];

			next
				if $subs->[0] == $sort->[0]
				;

			$changes ++;
			$requires_link ||= $subs->[1] == $subs->[1];

			$subs->[1]{children}[ $subs->[2] ] = $sort->[0];
		}

		$document->__link_children
			if $requires_link
			;

		return $changes;
	}

	sub dist_ini {
		state $dist_ini = do {
			require Config::INI::Reader;
			Config::INI::Reader->read_file (
				dist_root->child (q (dist.ini))
			);
		};
	}

	sub dist_module {
		state $dist_module = do {
			dist_ini->{_}{name} =~ s ([-]) (::)gr;
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

	sub ppi_replace {
		my ($document, $where, $invoke) = @_;

		my $changes = 0;

		for my $found (ppi_search ($document, $where)) {
			$found->insert_before ($_), $changes++
				for $invoke->(undef, $found)
				;
			$found->remove;
		}

		return $changes;
	}

	sub invoke (&;@) {
		my ($code, @rest) = @_;

		return (
			sub { local $_ = $_[1]; $code->(@_) },
			@rest,
		);
	}

	sub _path_iterator {
		return Path::Iterator::Rule::
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

	sub remove_previous_whitespaces {
		my ($element) = @_;

		while (my $previous_sibling = $element->previous_sibling) {
			last unless _is_ws ($element);
			$previous_sibling->remove;
		}
	}

	sub parse_options {
		my (@argv) = @_;

		my %options = (
			verbose  => 0,
		);

		GetOptionsFromArray (
			\ @argv,
			'include=s@' => sub { push @{ $options{include} //= [] }, $_[1] },
			'exclude=s@' => sub { push @{ $options{exclude} //= [] }, $_[1] },
			'verbose'    => \ $options{verbose},

			# policies options
			map {
				my $policy = $_;
				my $option = $_ =~ tr [_] [-]r =~ s (^policy[-]) ()r;
				($option => sub { push @{ $options{policies} //= [] }, $policy })
			}
			@POLICIES
		);

		push @{ $options{include} //= [] }, @argv
			if @argv
			;

		# Default values
		# ##########################################################

		$options{include}  //= \ @DEFAULT_INCLUDE;
		$options{policies} //= \ @POLICIES_DEFAULT;

		return \ %options;
	}

	sub policy_align_export_attributes  :Policy :Default {
		my ($document) = @_;

		my $changes = 0;
		my @operators = ppi_search $document, where {
			return 0 unless _is_token ($_, PPI::Token::Operator::, q (:));
			return 0 unless _is_sub ($_->parent);
			return 1;
		};

		for my $operator (@operators) {
			my $previous_sibling = $operator->previous_sibling;
			my $has_length       = length ($previous_sibling->content);

			unless (_is_ws ($previous_sibling)) {
				$has_length = 0;
				$operator->insert_before ($previous_sibling = PPI::Token::Whitespace::->new (q ( )));
			}

			my $new_length = ALIGN_EXPORT_BASE_COLUMN - $operator->sprevious_sibling->next_sibling->visual_column_number + 1;
			$new_length = 1 if $new_length < 1;

			if ($has_length != $new_length) {
				$previous_sibling->set_content (q ( ) x $new_length);
				$changes ++;
			}
		}

		return $changes;
	}

	sub policy_maintain_subs_order      :Policy :Default {
		my ($document) = @_;

		state $include_file_regex = _build_path_regex (
			q (lib/PPIx/Augment/Utils.pm),
			q (dev/ppi-sanity.pl),
			q (test-helper.pl),
			qr (lib/PPIx/Augment/DOM\b.*[.]pm),
		);

		return 0
			unless $document->filename =~ $include_file_regex
			;

		$document->index_locations
			if my $changes = 0
			+ _order_subs ($document, where { _is_sub_declaration ($_) })
			+ _order_subs ($document, where { _is_sub_definition ($_) })
			;

		return $changes;
	}

	sub policy_remove_unused_private_functions :Policy {
		my ($document) = @_;

		my @preserve;

		REDO:
		my %tokens =
			map { $_ => 1 }
			@preserve,
			(
				map { $_->content => 1 }
				grep { ! $_->parent->isa (PPI::Statement::Sub::) }
				ppi_search ($document, where { _is_token ($_, PPI::Token::Word::) })
			),
			(
				map { substr $_->content, 1 }
				grep { $_->symbol_type eq q (&) }
				ppi_search ($document, where { _is_token ($_, PPI::Token::Symbol::) })
			)
			;

		my $redo = 0;
		for my $sub (ppi_search ($document, where { _is_sub_definition ($_) })) {
			next unless $sub->name =~ qr (^_);
			next if exists $tokens{$sub->name};
			next if $sub->name =~ qr (^_exporter_);
			next if $sub->name =~ qr (^_generate_);

			say q (Found unused sub: ), $sub->name;
			remove_previous_whitespaces ($sub);
			$sub->remove;
			$redo = 1;
		}

		goto REDO if $redo;
	}

	sub policy_replace_quotes           :Policy :Default {
		my ($document) = @_;

		ppi_replace (
			$document,
			where {
				return 1 if $_->isa (PPI::Token::Quote::Double::);
				return 1 if $_->isa (PPI::Token::Quote::Single::);
				return 0;
			},
			invoke {
				my $content = $_->string;
				my $q = $content =~ m ([\$\@]) ? q (qq) : q (q);
				$_->set_content (qq ($q ($content)));
				$_;
			}
		);
	}

	sub policy_require_documentation    :Policy :Default {
		my ($document) = @_;

		my @policy_include = (
			q (lib/PPIx/Augment/Utils.pm),
		);

		return 0
			unless $document->filename =~ _build_path_regex (@policy_include)
			;

		my (%structure, %sections);
		my ($pod) = ppi_search $document, where { $_->isa (PPI::Token::Pod::) };

		my $file = $document->filename;

		warn qq ([$file] no pod)
			unless $pod
			;

		return
			unless $pod
			;


		my @sections = split qr (^(?==head[12]))sm, $pod->content;

		{
			my $current = [];

			for my $section (@sections) {
				my ($directive, $value) = $section =~ m (^ = (\w+) (?: \s+ (.*)))x;
				next unless defined $value;
				next unless length $value;
				warn qq ([$file] duplicated section '$value')
					if exists $sections{$value};
				$sections{$value} = $section;
				if ($directive eq q (head1)) {
					$structure{$value} = $current = [];
				} else {
					push @$current, $section;
				}
			}
		}

		my %insert_sections;
		my ($structure, $current_tag) = (q (), q ());
		my $current;

		for my $sub (_sort_subs_by_name (ppi_search ($document, where { _is_sub_declaration ($_) }))) {
			next
				unless my $tag = _sub_classification ($sub)
				;

			unless ($tag eq $current_tag) {
				my $section_name = uc ($tag) . q ( FUNCTIONS);
				die qq (Section '$section_name' doesn't exist)
					unless exists $structure{$section_name};
				$current_tag = $tag;
				$current = $insert_sections{$sections{$section_name}} = [];
				push @$current, $sections{$section_name};
			}

			my $prototype = List::Util::first {
				$_->isa (PPI::Token::Prototype::)
			} $sub->children;

			my $title = join q ( ) => grep $_, $sub->name, $prototype ? $prototype->content : undef;
			unless ($sections{$title}) {
				say q ([require-documentation] ), $title;
				$sections{$title} = qq (=head2 $title\n\n);
			}
			push @$current, $sections{$title};
		}

		my @result;
		my %inserted;

		#use DDP; p %insert_sections;

		for my $section (@sections) {
			next if exists $inserted{$section};
			if (exists $insert_sections{$section}) {
				push @result, my @insert = @{ $insert_sections{$section} };
				@inserted{@insert} = ();
				next;
			}
			push @result, $section;
		}

		$pod->set_content (join q () => @result);

		return scalar keys %inserted;
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

	sub policy_enforce_license_text     :Policy :Default {
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

	my @DEFAULT_INCLUDE = qw (bin lib t);

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
		my $config = App::config->new;
		my $options = & parse_options;

		$verbose = $options->{verbose};

		my $iterator = _build_path_iterator ($options);
		my $exit_value = 0;

		while (my $file = $iterator->()) {
			verbose { qq (==> $file) };

			eval {
				my $document = PPI::Document::->new (qq ($file));
				$document->tab_width (4);
				my $changes = 0;

				for my $policy (@{ $options->{policies} }) {
					verbose { q (  > policy ), $policy };

					if (__PACKAGE__->can ($policy)->($document)) {
						say qq ([$file] '$policy' modified document);
						$changes ++;
					};
				}

				if ($changes) {
					Path::Tiny::->new ($file)->spew ($document->serialize);
					$exit_value = 1;
				}

				1;
			} // do {
				say qq ([$file] Oops, something went wrong: $@);
			};
		}

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
		my $iterator = _path_iterator _includes_from_options @options;

		my $iterator = _path_iterator _includes_from_options @options;

		return 0;
	}

	sub verbose (&) {
		my $code = shift;

		say $code->() if $verbose;
	}
	sub where (&;@) {
		my ($code, @rest) = @_;

		return (
			sub { local $_ = $_[1]; $code->(@_) },
			@rest,
		);
	}

}

exit App::ppi_sanity::run (@ARGV)
	unless caller
	;

1;
