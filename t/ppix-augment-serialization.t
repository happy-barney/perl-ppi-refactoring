
use v5.14;
use warnings;

use require::relative 'test-helper.pl';

note <<'';
	Serializing PPIx::Augment documents should not modify them

my @fixtures = fixture_list;

plan tests => 1 + (@fixtures || 1);

fail "No fixtures found under ${\ fixture_root }"
	unless @fixtures;

use PPI;

no warnings 'redefine';
sub PPI::Token::Prototype::__TOKENIZER__on_char {
	my $class = shift;
	my $t     = shift;

	# Suck in until we find the closing paren (or the end of line)
	pos $t->{line} = $t->{line_cursor};
	die "regex should always match" if $t->{line} !~ m/\G([^\)]*\)?)/gcs;
	$t->{token}->{content} .= $1;
	$t->{line_cursor} += length $1;

	# Shortcut if end of line
	return 0 unless $1 =~ /\)$/;


	# Found the closing paren
	my $rv = $t->_finalize_token->__TOKENIZER__on_char( $t );
	$rv;
}

for my $fixture (sort @fixtures) {
	my $path = fixture_path ($fixture);
	my $content = fixture ($fixture);

	my $document = PPI::Document->new ("$path");
	my (@found) = $document->find ('PPI::Token::Prototype');

	it "fixture $fixture"
		=> got    => scalar PPI::Document->new ("$path")->serialize
		=> expect => $content
		;
}

had_no_warnings;

done_testing;
