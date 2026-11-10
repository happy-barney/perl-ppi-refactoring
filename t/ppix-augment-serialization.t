
use v5.14;
use warnings;

use Test::Load::Helper;

my @fixtures = fixture_list;
plan tests => 1 + (@fixtures || 1);

note <<'';
	Serializing documents without modification shouldn't change them

fail qq (No fixtures found under ${\ fixture_root })
	unless @fixtures;

for my $fixture (sort @fixtures) {
	my $path = fixture_path ($fixture);
	my $content = fixture ($fixture);

	my $document = PPI::Document->new (qq ($path));
	my (@found) = $document->find (PPI::Token::Prototype::);

	it qq (fixture $fixture)
		=> got    => scalar PPI::Document->new (qq ($path))->serialize
		=> expect => $content
		;
}

had_no_warnings;
done_testing;
