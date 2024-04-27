
use v5.14;
use warnings;

use Path::Tiny qw ();

use require::relative q (test-helper.pl);

note <<'';
	Poor man's protection against rebase errors

sub assume_pod_sections;

assume_pod_sections
	distribution_root->child (q (lib/PPIx/Augment/Utils.pm)),
	q (encoding utf-8),
	q (head1 NAME),
	q (head1 DESCRIPTION),
	q (head1 GLOSSARY) => [
		q (item current element),
		q (item effective element),
		q (item no element),
	],
	q (head1 ACCESSOR FUNCTIONS) => [
		q (head2 child),
		q (head2 children),
		q (head2 content),
		q (head2 current ()),
		q (head2 element),
		q (head2 first_child),
		q (head2 first_token),
		q (head2 last_child),
		q (head2 last_token),
		q (head2 next_sibling),
		q (head2 next_token),
		q (head2 no_element ()),
		q (head2 parent),
		q (head2 previous_sibling),
		q (head2 previous_token),
		q (head2 schild),
		q (head2 schildren),
		q (head2 snext_sibling),
		q (head2 sprevious_sibling),
		q (head2 top_element),
	],
	q (head1 BUILDER FUNCTIONS) => [
		q (head2 build_token_regexp_substitute ($)),
		q (head2 build_token_regexp_transliterate ($)),
		q (head2 build_token_structure ($)),
		q (head2 build_token_whitespace ($)),
		q (head2 build_token_word ($)),
	],
	q (head1 CLASSIFICATION FUNCTIONS) => [
		q (head2 exclude_all (&)),
		q (head2 it_is),
		q (head2 it_is_document),
		q (head2 it_is_element),
		q (head2 it_is_node),
		q (head2 it_is_not (&)),
		q (head2 it_is_significant),
		q (head2 it_is_statement),
		q (head2 it_is_statement_break),
		q (head2 it_is_statement_compound),
		q (head2 it_is_statement_data),
		q (head2 it_is_statement_end),
		q (head2 it_is_statement_expression),
		q (head2 it_is_statement_given),
		q (head2 it_is_statement_include),
		q (head2 it_is_statement_null),
		q (head2 it_is_statement_package),
		q (head2 it_is_statement_scheduled),
		q (head2 it_is_statement_sub),
		q (head2 it_is_statement_variable),
		q (head2 it_is_statement_when),
		q (head2 it_is_structure_block),
		q (head2 it_is_structure_condition),
		q (head2 it_is_structure_constructor),
		q (head2 it_is_structure_for),
		q (head2 it_is_structure_given),
		q (head2 it_is_structure_list),
		q (head2 it_is_structure_subscript),
		q (head2 it_is_structure_when),
		q (head2 it_is_token),
		q (head2 it_is_token_array_index),
		q (head2 it_is_token_attribute),
		q (head2 it_is_token_cast),
		q (head2 it_is_token_comment),
		q (head2 it_is_token_data),
		q (head2 it_is_token_end),
		q (head2 it_is_token_heredoc),
		q (head2 it_is_token_label),
		q (head2 it_is_token_magic),
		q (head2 it_is_token_number),
		q (head2 it_is_token_number_binary),
		q (head2 it_is_token_number_exp),
		q (head2 it_is_token_number_float),
		q (head2 it_is_token_number_hex),
		q (head2 it_is_token_number_octal),
		q (head2 it_is_token_number_version),
		q (head2 it_is_token_operator),
		q (head2 it_is_token_pod),
		q (head2 it_is_token_prototype),
		q (head2 it_is_token_quote),
		q (head2 it_is_token_quote_double),
		q (head2 it_is_token_quote_interpolate),
		q (head2 it_is_token_quote_literal),
		q (head2 it_is_token_quote_single),
		q (head2 it_is_token_quotelike),
		q (head2 it_is_token_quotelike_backtick),
		q (head2 it_is_token_quotelike_command),
		q (head2 it_is_token_quotelike_readline),
		q (head2 it_is_token_quotelike_regexp),
		q (head2 it_is_token_quotelike_words),
		q (head2 it_is_token_regexp),
		q (head2 it_is_token_regexp_match),
		q (head2 it_is_token_regexp_substitute),
		q (head2 it_is_token_regexp_transliterate),
		q (head2 it_is_token_separator),
		q (head2 it_is_token_structure),
		q (head2 it_is_token_symbol),
		q (head2 it_is_token_whitespace),
		q (head2 it_is_token_word),
		q (head2 ppi_bool ($)),
		q (head2 ppi_exclude ()),
		q (head2 ppi_exclude_all ()),
		q (head2 ppi_include ()),
		q (head2 ppix_exclude ()),
		q (head2 ppix_exclude_all ()),
		q (head2 ppix_include ()),
	],
	q (head1 TRANSFORMATION FUNCTIONS) => [
	],
	q (head1 TRAVERSAL FUNCTIONS) => [
	],
	q (head1 AUTHOR),
	q (head1 COPYRIGHT AND LICENCE),
	;

done_testing;

sub assume_pod_sections {
	my $file = shift;
	my @sections = map { Ref::Util::is_plain_arrayref ($_) ? sort { $a cmp $b } @$_ : $_ } @_;

	my %mandatory_command = map +($_ => 1), qw (
		encoding
		head1
		head2
	);

	for my $line (Path::Tiny::->new ($file)->lines) {
		next
			unless $line =~ m (^ = (?<command>\w+) \s* (?<section>.+) $)x
			;

		my ($command, $section) = ($+{command}, $+{section});
		if (@sections && ($sections[0] eq $section || $sections[0] eq qq ($command $section))) {
			pass qq (section $sections[0] should exist in given order);
			shift @sections;
			next;
		}

		next
			unless exists $mandatory_command{$command}
			;

		return fail qq (Section '=$command $section' isn't expected but exists)
			=> diag => sub { @sections ? qq (head expectation: $sections[0]) : qq (at the end of expectations) };
	}

	if (@sections) {
		fail qq (Sections should exists in given order)
			=> diag => sub { map qq ( - $_\n), @sections }
			;
	}
}

1;

