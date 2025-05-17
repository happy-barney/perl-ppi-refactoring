#!/usr/bin/env perl

use v5.14;
use strict;

use Attribute::Handlers;
use PPI;
use Path::Iterator::Rule;
use Scalar::Util qw (blessed);

use FindBin;
use lib qq ($FindBin::Bin/lib);

#use PPIx::Augment::Utils;

our $file;
our @exclude;
our $verbose;

my @POLICIES;
my %POLICIES_OPTIONS;
my @POLICIES_DEFAULT;
my @POLICIES_EFFECTIVE;

our @CHECK_DUPED_SUBS = qw (
	content element no_element
	ppi_.* ppix_.* exclude_all
	_build_invoke _build_where invoke where
);

our @DEFAULT_CLEANUPS = (
	q (align_export_attributes),
	q (remove_duplicated_subs),
	q (remove_multiple_newlines),
	q (remove_unused_private_functions),
	q (replace_class_literal),
	q (replace_quotes),
	q (maintain_subs_order),
	q (require_documentation),
);

sub Policy                          :ATTR(CODE,BEGIN) {
	my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

	my $name = *{$symbol}{NAME};
	my $option = $name =~ tr [_] [-]r =~ s (^policy[-]) ()r;

	push @POLICIES, $name;
	$POLICIES_OPTIONS{$option} = sub { push @POLICIES_EFFECTIVE, $name };
}

sub Default                         :ATTR(CODE,BEGIN) {
	my ($package, $symbol, $referent, $attr, $data, $phase, $filename, $linenum) = @_;

	my $name = *{$symbol}{NAME};

	push @POLICIES_DEFAULT, $name;
}

sub invoke (&;@);
sub where (&;@);
sub verbose (&);

sub _build_path_iterator {
	my ($exclude, $include) = @_;

	my $exclude_regex = _build_path_regex (@{ $exclude // [] });

	$include = [ qw [bin lib t]]
		unless $include && @$include
		;

	my $rule = Path::Iterator::Rule
		->new
		->file
		->or (
			Path::Iterator::Rule->new->name (qr ( [.] (?: pm | pl | t ) $ )x),
			Path::Iterator::Rule->new->shebang (qr (^[#]! .* \b perl \b )x),
		)
		;

	$rule = $rule ->not (sub { $_ =~ $exclude_regex })
		if $exclude_regex
		;

	$rule->iter (@$include, { recurse => 1 });
}

sub _build_path_regex {
	return
		unless my $regex = join q (|), map { qr ((?:\Q$_\E)) } @_
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

sub _effective_element {
	blessed ($_[0]) ? shift : $_;
}

sub _is {
	my ($element, $class) = @_;

	return unless $element;
	return $element->isa ($class);
}

sub _is_comment {
	my ($element, $regex) = @_;

	_is_token ($element, PPI::Token::Comment::, $regex);
}

sub _is_sub {
	return 0 unless $_[0]->isa (PPI::Statement::Sub::);
	return 1;
}

sub _is_sub_alignment_comment {
	my ($element) = @_;

	_is_comment ($element, qr (^# ;));
}

sub _is_sub_definition {
	my ($element) = @_;

	return 0 unless $element;
	return 0 unless $element->isa (PPI::Statement::Sub::);
	return 0 unless $element->block;
	return 1;
}

sub _is_sub_declaration {
	my ($element) = @_;

	return 0 unless $element;
	return 0 unless $element->isa (PPI::Statement::Sub::);
	return 0 if     $element->block;
	return 1;
}

sub _is_named_sub {
	my ($element) = @_;

	return 0 unless _is_sub ($element);
	return 0 unless $element->name;
	return 1;
}

sub _is_named_sub_definition {
	my ($element) = @_;

	return 0 unless _is_sub_definition ($element);
	return 0 unless $element->name;
	return 1;
}

sub _is_token {
	my ($element, $class, $regex) = @_;

	return 0 unless $element;
	return 0 unless $element->isa ($class);
	return 1 unless $regex;
	return $element->content eq $regex ? 1 : 0
		unless ref $regex;
	return $element =~ $regex ? 1 : 0;
}

sub _is_ws {
	my ($element, $regex) = @_;

	_is_token ($element, PPI::Token::Whitespace::, $regex);
}

sub _is_insignificant {
	my ($element) = @_;

	_is_ws ($element) || _is_comment ($element);
}

sub _is_nl {
	my ($element) = @_;
	_is_ws ($element, qr (^\n));
}

sub _it_is_token {
	my ($class, $regex) = @_;

	$regex = qr (^\Q$regex\E$)
		unless ref $regex
		;

	return 0 unless $_;
	return 0 unless $_->isa ($class);
	return 0 if $regex && $_ !~ $regex;

	return 1;
}

sub _sub_classification {
	my ($sub) = @_;

	my @attributes = grep { $_->isa (PPI::Token::Attribute::) } $sub->children;

	return q () unless @attributes;
	return q () unless $attributes[0]->identifier eq q (Exported);
	return $attributes[0]->parameters;
}

sub _sub_tag {
	my ($sub) = @_;

	join q (/), _sub_classification ($sub), $sub->name;
}

sub _find_named_subs {
	my ($document) = @_;

	find ($document, where { _is_named_sub_definition ($_) });
}

sub _find_next_named_sub {
	my ($element) = @_;

	while ($element = $element->snext_sibling) {
		return $element if _is_named_sub_definition ($element);
	}

}

sub _full_sub_name {
	my ($sub) = @_;

	my $name = $sub->name;
	my $package;
	my $element = $sub;

	while ($element = $element->parent) {
		next unless _is ($element, PPI::Structure::Block::);
		next unless _is ($element->parent, PPI::Statement::Package::);

		$package = $element->parent;
		last;
	}

	if ($package) {
		$name = $package->namespace . q (::) . $name;
	}

	return $name;
}

sub _sorted_named_subs {
	my ($document) = @_;

	return sort {
		_sub_classification ($a) cmp _sub_classification ($b)
		or
		_cmp_sub_names ($a->name, $b->name)
	} find ($document, where { _is_named_sub_definition ($_) });
}

sub _insert_after {
	my ($element, @elements) = @_;

	for my $insert (@elements) {
		$element->insert_after ($insert);
		$element = $element->next_sibling;
	}

	return $element;
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

sub ppi_dump {
	use PPI::Dumper;
	PPI::Dumper::->new ($_)->print for @_;
}

sub find {
	my ($document, $where) = @_;

	@{ $document->find ($where) || [] };
}

sub next_sibling {
	my ($element) = @_;

	return $element unless $element;
	return $element->next_sibling;
}

sub invoke (&;@) {
	my ($code, @rest) = @_;

	return (
		sub { local $_ = $_[1]; $code->(@_) },
		@rest,
	);
}

sub where (&;@) {
	my ($code, @rest) = @_;

	return (
		sub { local $_ = $_[1]; $code->(@_) },
		@rest,
	);
}

sub replace {
	my ($document, $where, $invoke) = @_;

	for my $found (find ($document, $where)) {
		$found->insert_before ($_)
			for $invoke->(undef, $found)
			;
		$found->remove;
	}
}

sub remove {
	my ($document, $where) = @_;

	for my $found (find ($document, $where)) {
		$found->remove;
	}
}

sub policy_align_export_attributes  :Policy :Default {
	my ($document) = @_;

	my @policy_include = (
		q (lib/PPIx/Augment/Utils.pm),
		q (ppi-cleanup.pl),
	);

	return
		unless $document->filename =~ _build_path_regex (@policy_include)
		;

	my @operators = find $document, where {
		return 0 unless _is_token (PPI::Token::Operator::, q (:));
		return 0 unless _is_sub ($_->parent);
		return 1;
	};

	for my $operator (@operators) {
		my $column = $operator->location->[2] - $operator->parent->first_element->location->[2];
		unless (_is_ws ($operator->previous_sibling)) {
			$column += 1;
			$operator->insert_before (PPI::Token::Whitespace::->new (q ( )));
		}

		my $diff = 36 - $column;
		my $length = $diff + length $operator->previous_sibling->content;
		$length = 1 if $length < 1;

		$operator->previous_sibling->set_content (q ( ) x $length);
	}
}

sub check_duped_subs {
	my ($document) = @_;

	return
		unless @CHECK_DUPED_SUBS
		;

	my $exit_status = 0;
	my $regex = qr (^(${\ join q (|) => @CHECK_DUPED_SUBS })$);

	my %found;
	for my $sub (find ($document, where { _is_sub_definition ($_) })) {
		next if $regex && $sub->name !~ $regex;

		say $sub->name and $exit_status = 1
			if 2 == ++$found{$sub->name};
	}

	exit $exit_status if $exit_status;
}

sub ensure_public_documentation {
	my ($document) = @_;

	return
		unless my %subs = _find_named_subs ($document)
		;

	my (@pod) = find ($document, sub { $_[0]->isa (PPI::Token::Pod::) });
	if (@pod) {
	}
}

sub maintain_subs_order {
	my ($document) = @_;

	my $apply = 0;
	$apply = 1 if $document->filename =~ qr ([.]pm$);
	$apply = 1 if $document->filename =~ qr (\btest-helper[.]pl$);

	return unless $apply;

	$document->index_locations;

	_maintain_order_of_sub_definitions  ($document);
	_maintain_order_of_sub_declarations ($document);
}

sub remove_duplicated_subs {
	my ($document) = @_;

	{
		my %seen;
		for my $sub (find ($document, where { _is_sub_declaration ($_) })) {
			my $full_name = _full_sub_name ($sub);
			next unless $seen{$full_name . $sub->content}++;

			while (_is_ws (my $element = $sub->next_sibling)) {
				$element->remove;
			}

			$sub->remove;
		}
	}

	{
		# unify sub declarations
		my (%names, %seen);
		for my $sub (find ($document, where { _is_named_sub_definition ($_) })) {
			my $full_name = _full_sub_name ($sub);

			unless ($seen{$full_name . $sub->content}++) {
				say qq ([$file] [sub::dup] ${\ $sub->name } at line ${\ $sub->line_number } (first defined at ${\ $names{$sub->name} }))
					if exists $names{$full_name};
					;
				$names{$full_name} = $sub->line_number;
				next;
			}

			while (_is_ws (my $element = $sub->next_sibling)) {
				$element->remove;
			}

			$sub->remove;
		}
	}

	$document->index_locations;
}

sub remove_multiple_newlines {
	my ($document) = @_;

	remove $document, where {
		return 0 unless _is_nl ($_);
		return 0 unless _is_nl (next_sibling ($_));
		return 0 unless _is_nl (next_sibling (next_sibling ($_)));
		return 1;
	};
}

sub remove_previous_whitespaces {
	my ($element) = @_;

	while (my $previous_sibling = $element->previous_sibling) {
		last unless $previous_sibling;
		last unless $previous_sibling->isa (PPI::Token::Whitespace::);
		$previous_sibling->remove;
	}
}

sub remove_separator_comments {
	my ($document) = @_;

	remove $document, where { _is_comment ($_, qr (######)) };
}

sub remove_sub_alignment_comments {
	my ($document) = @_;

	remove $document, where {
		return 1 if _is_sub_alignment_comment ($_);
		return 1 if _is_ws ($_) && _is_sub_alignment_comment (next_sibling ($_));
		return 0;
	};
}

sub remove_unused_private_functions {
	my ($document) = @_;

	return
		if $document->filename =~ qr (\btest-helper[.]pl$)
		;

	my @preserve = qw (
		_accessor_list
		_accessor_list_node
		_accessor_scalar
		_accessor_scalar_node
		_arrayref_expand
		_build_element
		_build_token
		_create_element
		_element_key
		_its
		_transformation_elements
	);

	REDO:
	my %tokens =
		map { $_ => 1 }
		@preserve,
		(
			map { $_->content => 1 }
			grep { ! $_->parent->isa (PPI::Statement::Sub::) }
			find ($document, where { $_->isa (PPI::Token::Word::) })
		),
		(
			map { substr $_->content, 1 }
			grep { $_->symbol_type eq q (&) }
			find ($document, where { $_->isa (PPI::Token::Symbol::) })
		)
	;

	my $redo = 0;
	for my $sub (find ($document, where { _is_sub_definition ($_) })) {
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

sub replace_quotes {
	my ($document) = @_;

	replace $document,
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
		};
}

sub replace_class_literal {
	my ($document) = @_;

	replace $document,
		where {
			return   if $_->isa (PPI::Statement::Include::);
			return 0 unless $_->isa (PPI::Token::Quote::Literal::);
			return 0 unless $_->string =~ m (^ \w+ (?: :: \w+)+ (?: :: )? $)x;
			return 0 if $_->sprevious_sibling eq q (use_ok);
			return 1;
		}
		invoke {
			my $literal = $_->string;
			$literal .= q (::) unless $literal =~ m ( :: $)x;

			PPI::Token::Word->new ($literal);
		};
}

sub require_documentation {
	my ($document) = @_;

	my (%structure, %sections);
	my ($pod) = find $document, where { $_->isa (PPI::Token::Pod::) };

	return unless $pod;
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

	for my $sub (_sorted_named_subs ($document)) {
		next
			unless my $tag = _sub_classification ($sub);

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
}

sub space_code_symbol {
	replace shift,
		where {
			return 0 unless $_->isa (PPI::Token::Symbol::);
			return 0 unless $_->symbol_type eq q (&);
			return 1;
		}
		invoke {
			(
				PPI::Token::Operator::   ->new ($_->symbol_type),
				PPI::Token::Whitespace:: ->new (q ( )),
				PPI::Token::Word::       ->new (substr $_->content, 1),
			)
		};
}

sub verbose (&) {
	my $code = shift;

	say $code->() if $verbose;
}

use Getopt::Long;

GetOptions (
	%POLICIES_OPTIONS,
	'exclude=s@', \ @exclude,
	'verbose', \ $verbose,
);

sub main {
	my $iterator = _build_path_iterator (\ @exclude, \ @ARGV);

	@ARGV = ();
	@POLICIES_EFFECTIVE = @POLICIES_DEFAULT
		unless @POLICIES_EFFECTIVE
		;

	map { __PACKAGE__->can ($_) // die qq (Unknown cleanup '$_') } @POLICIES_EFFECTIVE;

	while ($file = $iterator->()) {
		verbose { q (==> ), $file };

		eval {
			my $document = PPI::Document->new (qq ($file));
			my $orig = $document->content;
			my $content = $orig;

			for my $policy (@POLICIES_EFFECTIVE) {
				verbose { q (  > apply policy ), $policy };
				__PACKAGE__->can ($policy)->($document);
				next if $document->content eq $content;
				say qq ([$file] '$policy' modified document);
				$content = $document->content;
			}

			$document->save ($file)
				unless $document->content eq $orig;

			1;
		} // do {
			say q (Processing ), $file, q ( failed);
			say $@;
		};
	}
}

main unless caller;


