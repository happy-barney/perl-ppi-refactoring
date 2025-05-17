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
	use Path::Tiny;

	use constant ALIGN_EXPORT_BASE_COLUMN => 40;

	BEGIN {
		App::ppi_sanity::attributes->import;
		App::ppi_sanity::config::->import;
		App::ppi_sanity::logger::->import;
	}

	my @DEFAULT_INCLUDE = qw (bin lib t);

	my @DEFAULT_INCLUDE = qw (bin lib t);

	sub where (&;@);

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
				join q ([/]+), map { quotemeta ($_) } split qr ([/]), $_
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

		# TODO: move all together

		return
			unless my @subs = find ($document, where { _is_sub_declaration ($_) });

		my $insert_after = $subs[0]->sprevious_sibling;
		my @sort = sort {
			_sub_classification ($a) cmp _sub_classification ($b)
				or
				_cmp_sub_names ($a->name, $b->name)
			} @subs;

		my $subs = join q (-), map { $_->name } @subs;
		my $sort = join q (-), map { $_->name } @sort;

		return if $subs eq $sort;

		@sort = map {
			my @insert = ($_->clone);
			while (_is_insignificant ($_->previous_sibling)) {
				unshift @insert, $_->previous_sibling->clone;
				$_->previous_sibling->remove;
			}
			$_->remove;
			\ @insert
		} @sort;

		my $insert_before = $insert_after->next_sibling;

		for my $sort (@sort) {
			$insert_before->parent->__insert_before_child ($insert_before, @$sort);
		}
	}

	sub _maintain_order_of_sub_definitions {
		my ($document) = @_;

		my ($insert_head) = find ($document, where { _is_named_sub_definition ($_) });
		my @sorted = _sorted_named_subs ($document);

		while (@sorted) {
			if ($insert_head->name eq $sorted[0]->name) {
				shift @sorted;
				if (my $next_sub = _find_next_named_sub ($insert_head)) {
					$insert_head = $next_sub;
				}
				next;
			}

			my $sorted_tag = _sub_tag ($sorted[0]);
			my $head_tag   = _sub_tag ($insert_head);

			if ($head_tag gt $sorted_tag) {
				my $inserting = my $point = shift @sorted;
				my @elements;
				while (_is_ws (my $previous_sibling = $point->previous_sibling)) {
					unshift @elements, $previous_sibling;
					$point = $previous_sibling;
				}

				$insert_head->__insert_before (map $_->remove, $inserting, @elements);

				next;
			}

			if ($head_tag lt $sorted_tag) {
				my $inserting = my $point = shift @sorted;
				my @elements;
				while (_is_ws (my $previous_sibling = $point->previous_sibling)) {
					unshift @elements, $previous_sibling;
					$point = $previous_sibling;
				}

				$insert_head->__insert_after (map $_->remove, @elements, $inserting);
				$insert_head = $inserting;
				next;
			}
		}
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

	sub policy_maintain_subs_order      :Policy :Default {
		my ($document) = @_;

		my $apply = 0;
		$apply = 1 if $document->filename =~ qr ([.]pm$);
		$apply = 1 if $document->filename =~ qr (\btest-helper[.]pl$);

		return unless $apply;

		$document->index_locations;

		_maintain_order_of_sub_definitions  ($document);
		_maintain_order_of_sub_declarations ($document);
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
		my $options = & parse_options;

		$verbose = $options->{verbose};

		my $iterator = _build_path_iterator ($options);

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

				Path::Tiny::->new ($file)->spew_utf8 ($document->content)
					if $changes
					;

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
