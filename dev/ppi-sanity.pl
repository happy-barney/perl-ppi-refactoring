#!/usr/bin/env perl

use v5.14;
use strict;

package App::ppi_sanity {

	use Attribute::Handlers;
	use Getopt::Long qw (GetOptionsFromArray);
	use Path::Iterator::Rule;
	use Path::Tiny;
	use PPI;

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

	sub run {
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
