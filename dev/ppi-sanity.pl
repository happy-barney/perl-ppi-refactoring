#!/usr/bin/env perl

use v5.14;
use warnings;

package App::ppi_sanity {

	use Attribute::Handlers;
	use Getopt::Long qw (GetOptionsFromArray);
	use Path::Iterator::Rule;
	use Path::Tiny;
	use PPI;
	use Ref::Util;

	use constant ALIGN_EXPORT_BASE_COLUMN => 40;

	my @DEFAULT_INCLUDE = qw (bin lib t);

	my @POLICIES;
	my @POLICIES_DEFAULT;
	my $verbose = 0;

	sub Policy                          :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @POLICIES, *{$symbol}{NAME};
	}

	sub Default                         :ATTR(CODE,BEGIN) {
		my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

		push @POLICIES_DEFAULT, *{$symbol}{NAME};
	}

	sub verbose (&);
	sub where (&;@);
	sub invoke (&;@);

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

	sub _cmp_sub_names {
		my ($name_a, $name_b) = @_;

		my $result = ($name_a cmp $name_b);

		return $result if $name_a =~ m (^_) or $name_b =~ m (^_);
		return -1 if $name_a eq q (new);
		return 1 if $name_b eq q (new);
		return $result;
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
		$options{policies} //= \ @POLICIES_DEFAULT;

		return \ %options;
	}

	sub remove_previous_whitespaces {
		my ($element) = @_;

		while (my $previous_sibling = $element->previous_sibling) {
			last unless _is_ws ($element);
			$previous_sibling->remove;
		}
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

	sub run {
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

		exit $exit_value;
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

App::ppi_sanity::run (@ARGV)
	unless caller
	;
