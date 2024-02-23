
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
		q (head2 current ()),
		q (head2 element),
		q (head2 no_element ()),
	],
	q (head1 BUILDER FUNCTIONS),
	q (head1 CLASSIFICATION FUNCTIONS) => [
		q (head2 exclude_all (&)),
		q (head2 it_is),
		q (head2 it_is_element),
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
		q (head2 ppi_exclude ()),
		q (head2 ppi_exclude_all ()),
		q (head2 ppi_include ()),
		q (head2 ppix_exclude ()),
		q (head2 ppix_exclude_all ()),
		q (head2 ppix_include ()),
	],
	q (head1 TRANSFORMATION FUNCTIONS),
	q (head1 TRAVERSAL FUNCTIONS),
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
		head3
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

