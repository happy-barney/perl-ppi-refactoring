#!/usr/bin/env perl

use v5.14;
use warnings;

package App::dwp_sanity {

	use Attribute::Handlers;
	use Term::ReadKey;

	use constant SYNOPSIS_GAP => 2;

	my %COMMANDS;

	sub Command                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		my $name = *{$symbol}{NAME};
		my $command = _normalise_command_name ($name);

		$COMMANDS{$command}{name}     = $name;
		$COMMANDS{$command}{handler}  = $referent;
		$COMMANDS{$command}{synopsis} = $data;
	}

	sub _build_command_character_regex {
		my ($command) = @_;

		my $regex = join q (.*-) => split q (), $command;

		return qr (^$regex);
	}

	sub _build_command_component_regex {
		my ($command) = @_;

		my $regex = join q (.*-) => split q (-), $command;

		return qr (^$regex);
	}

	sub _normalise_command_name {
		my ($name) = @_;

		return lc $name =~ s (^command_) ()r =~ tr [_] [-]r;
	}

	sub _search_command_candidate {
		my ($command) = @_;

		return $command
			if exists $COMMANDS{$command}
			;

		for my $regex (
			_build_command_component_regex ($command),
			_build_command_character_regex ($command),
		) {
			my @matches = grep { $_ =~ $regex } keys %COMMANDS;

			return $matches[0]
				if @matches == 1
				;
		}

		return undef;
	}

	sub _search_command_handler {
		my ($command) = @_;

		$command = _search_command_candidate ($command);

		return
			unless my $command_spec = $COMMANDS{_normalise_command_name ($command)}
			;

		return $command_spec->{handler};
	}

	sub command_class_composition        :Command(Show mro, parent classes and roles for a package file) {
		my (@argv) = @_;

		return Class_Composition->run (@argv);
	}

	sub command_help                    :Command(Show this help) {
		my @commands = (q (help), sort { $a cmp $b } grep { $_ ne q (help) } keys %COMMANDS);

		my $width = 0;
		$width = length ($_) > $width ? length ($_) : $width
			for @commands
			;

		my $index = 0;
		for my $command (@commands) {
			say q ()
				if $index == 1
				;

			say sprintf (
				qq (%-${\ $width }s%s%s),
				$command,
				q ( ) x SYNOPSIS_GAP,
				$COMMANDS{$command}{synopsis},
			);

			$index ++;
		}

		return 0;
	}

	sub command_hi                      :Command(Say hi) {
		say q (hi there);

		return 0;
	}

	sub command_terminal_width          :Command(Show width of terminal) {
		my ($width) = Term::ReadKey::GetTerminalSize ();

		say $width;

		return 0;
	}

	sub invalid_command {
		my ($command) = @_;

		say qq (Unknown command '$command');

		return 1;
	}

	sub run {
		my (@argv) = @_;

		my $command = shift (@argv) // q (help);

		return invalid_command ($command)
			unless my $handler = _search_command_handler ($command);
			;

		return $handler->(@argv);
	}

}

exit App::dwp_sanity::run (@ARGV)
	unless caller
	;

package Class_Composition {

	use PPI;
	use PPIx::Augment::Utils;

	use constant REPORT_DIVIDER => q (*** ****************************************************************);

	sub new {
		my ($class, %args) = @_;

		return bless {
			classes   => {},
			mro       => {},
			resolving => {},
			%args,
		}, $class;
	}

	sub _class_algorithm {
		my ($document) = @_;

		my ($mro_use) = ppix_search $document, where { it_is_use_statement (&element, { module => q (mro) }) };

		return q (dfs) unless $mro_use;

		my ($mode) = grep { it_is_token_quote ($_) && $_->string eq q (c3) } schildren ($mro_use);

		return $mode ? q (c3) : q (dfs);
	}

	sub _class_names_from_elements {
		my (@elements) = @_;

		return
			map  { it_is_token_quotelike_words ($_) ? $_->literal : it_is_token_quote ($_) ? $_->string : qq ($_) }
			grep { it_is_token_word ($_) || it_is_token_quote ($_) || it_is_token_quotelike_words ($_) }
			map  { it_is_structure_list ($_) ? schildren ($_) : $_ }
			@elements
			;
	}

	sub _is_isa_declaration {
		return 1 if is_isa_alter ();
		return 1 if is_isa_assign ();
		return 1 if is_isa_base ();
		return 1 if is_isa_extends ();
		return 1 if is_isa_mojo_base ();
		return 1 if is_isa_parent ();
		return 0;
	}

	sub _isa_head_symbol {
		my ($element) = @_;

		my $head = first_schild ($element);

		$head = schild ($element, 1)
			if it_is_token_word ($head, qr (^ (?: our | local | my ) $)x)
			;

		return $head;
	}

	sub _isa_names {
		my ($statement) = @_;

		local $_ = $statement;

		return _isa_names_alter     ($statement) if is_isa_alter     ();
		return _isa_names_assign    ($statement) if is_isa_assign    ();
		return _isa_names_mojo_base ($statement) if is_isa_mojo_base ();
		return _isa_names_include   ($statement) if is_isa_base      ();
		return _isa_names_include   ($statement) if is_isa_parent    ();
		return _isa_names_extends   ($statement) if is_isa_extends   ();
		return ();
	}

	sub _isa_names_alter {
		my ($element) = @_;

		my $head   = first_schild ($element);
		my $target = snext_sibling ($head);
		$target = first_schild ($target)
			if it_is_structure_list ($target)
			;

		return _class_names_from_elements (next_siblings ($target));
	}

	sub _isa_names_assign {
		my ($element) = @_;

		my $symbol   = _isa_head_symbol ($element);
		my $operator = snext_sibling ($symbol);

		return _class_names_from_elements (next_siblings ($operator));
	}

	sub _isa_names_extends {
		my ($element) = @_;

		return _class_names_from_elements (next_siblings (first_schild ($element)));
	}

	sub _isa_names_include {
		my ($element) = @_;

		my @names;
		my @tail = schildren ($element, 2, -1);

		while (@tail) {
			my $token = shift @tail;

			if (it_is_token_operator ($token, q (-))) {
				shift @tail;
				next;
			}

			push @names, _class_names_from_elements ($token);
		}

		# strip flags PPI merged into a single '-flag' word (eg. -norequire, -base)
		return grep { ! m (^ [-] )x } @names;
	}

	sub _isa_names_mojo_base {
		my ($element) = @_;

		my @names = _isa_names_include ($element);

		return @names if @names;
		return (q (Mojo::Base));
	}

	sub _load_class {
		my ($self, $package) = @_;

		return $self->{classes}{$package} //= do {
			my $file     = $self->{prefix} . _package_to_relative_path ($package);
			my $document = -f $file && PPI::Document::->new ($file);

			{
				name      => $package,
				file      => $document ? $file : undef,
				algorithm => $document ? _class_algorithm ($document) : q (dfs),
				isa       => [ $document ? list_direct_isa   ($document) : () ],
				roles     => [ $document ? list_direct_roles ($document) : () ],
			};
		};
	}

	sub _merge_c3 {
		my ($self, $package, $parents, $sequences) = @_;

		my @lists  = (@$sequences, [ @$parents ]);
		my @merged = ($package);

		while (grep { @$_ } @lists) {
			my $candidate;

			CANDIDATE:
			for my $list (@lists) {
				next unless @$list;
				$candidate = $list->[0];

				for my $other (@lists) {
					next if $other == $list;
					next unless grep { $_ eq $candidate } @{$other}[ 1 .. $#$other ];
					undef $candidate;
					next CANDIDATE;
				}

				last CANDIDATE;
			}

			# inconsistent hierarchy: fall back to first-occurrence order
			$candidate //= (grep { @$_ } @lists)[0][0];

			push @merged, $candidate;
			$_ = [ grep { $_ ne $candidate } @$_ ] for @lists;
		}

		return @merged;
	}

	sub _merge_dfs {
		my ($self, $package, $sequences) = @_;

		my %seen;

		return grep { ! $seen{$_} ++ } $package, map { @$_ } @$sequences;
	}

	sub _package_to_relative_path {
		my ($package) = @_;

		my $path = $package =~ s (::) (/)xgr;

		return $path . q (.pm);
	}

	sub _print_report {
		my ($self, $package) = @_;

		for my $name ($self->effective_mro ($package)) {
			my $spec = $self->_load_class ($name);

			say REPORT_DIVIDER;
			say qq (package $name);
			say qq (   with $_) for @{ $spec->{roles} };
		}
	}

	sub _resolve_prefix {
		my ($file, $package) = @_;

		my $relative = _package_to_relative_path ($package);

		return substr ($file, 0, length ($file) - length ($relative))
			if length ($file) >= length ($relative)
			&& substr ($file, - length ($relative)) eq $relative
			;

		return $file =~ s ([^/]+ $) ()xr;
	}

	sub _usage {
		my ($message) = @_;

		say $message if defined $message;
		say q (Usage: class-composition FILE);

		return 1;
	}

	sub effective_mro {
		my ($self, $package) = @_;

		return @{ $self->{mro}{$package} }
			if $self->{mro}{$package}
			;

		return ($package)
			if $self->{resolving}{$package}
			;

		local $self->{resolving}{$package} = 1;

		my $spec      = $self->_load_class ($package);
		my @parents   = @{ $spec->{isa} };
		my @sequences = map { [ $self->effective_mro ($_) ] } @parents;

		my @order = $spec->{algorithm} eq q (c3)
			? $self->_merge_c3 ($package, \@parents, \@sequences)
			: $self->_merge_dfs ($package, \@sequences)
			;

		return @{ $self->{mro}{$package} = \@order };
	}

	sub is_isa_alter {
		my $element = &element;

		return ppi_exclude unless it_is_statement ($element);

		my $head = first_schild ($element);
		return ppi_exclude unless it_is_token_word ($head, qr (^ (?: push | unshift ) $)x);

		my $target = snext_sibling ($head);
		$target = first_schild ($target)
			if it_is_structure_list ($target)
			;

		return ppi_exclude unless it_is_token_symbol ($target, q (@ISA));
		return ppi_include;
	}

	sub is_isa_assign {
		my $element = &element;

		return ppi_exclude unless it_is_statement ($element);

		my $symbol = _isa_head_symbol ($element);
		return ppi_exclude unless it_is_token_symbol ($symbol, q (@ISA));
		return ppi_exclude unless it_is_token_operator (snext_sibling ($symbol), q (=));
		return ppi_include;
	}

	sub is_isa_base {
		return it_is_use_statement (&element, { module => q (base) });
	}

	sub is_isa_extends {
		my $element = &element;

		return ppi_exclude unless it_is_statement ($element);
		return ppi_exclude unless it_is_token_word (first_schild ($element), q (extends));
		return ppi_include;
	}

	sub is_isa_mojo_base {
		return it_is_use_statement (&element, { module => q (Mojo::Base) });
	}

	sub is_isa_parent {
		return it_is_use_statement (&element, { module => q (parent) });
	}

	sub is_role_with {
		my $element = &element;

		return ppi_exclude unless it_is_statement ($element);
		return ppi_exclude unless it_is_token_word (first_schild ($element), q (with));
		return ppi_include;
	}

	sub list_direct_isa {
		my ($doc) = @_;

		return
			map { _isa_names ($_) }
			ppix_search $doc, where { _is_isa_declaration () }
			;
	}

	sub list_direct_roles {
		my ($doc) = @_;

		return
			map { _class_names_from_elements (next_siblings (first_schild ($_))) }
			ppix_search $doc, where { is_role_with () }
			;
	}

	sub run {
		my ($class, @argv) = @_;

		my ($file) = @argv;

		return _usage ()
			unless defined $file
			;

		my $document = PPI::Document::->new ($file);

		return _usage (qq (Unable to parse '$file'))
			unless $document
			;

		my ($package_element) = ppix_search $document, where { it_is_statement_package () };

		return _usage (qq (No package declaration found in '$file'))
			unless $package_element
			;

		my $package = $package_element->namespace;
		my $self    = $class->new (prefix => _resolve_prefix ($file, $package));

		$self->_print_report ($package);

		return 0;
	}

}
