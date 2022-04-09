
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

plan tests => 4;

{
	my $document = document '1 + 2 + 3';

	my ($one, $two) = ppix_find $document, where { it_is_token_number };

	my $wrap = elements_wrap (
		PPI::Statement::,
		($one->parent->children)[ child_index ($one) .. child_index ($two) ],
	);

	it "serialization should not differ from origin"
		=> got    => $document->serialize
		=> expect => '1 + 2 + 3'
		;
}

{
	my $document = document my $origin = <<'DOCUMENT';
say <<'FOO';
foo1
foo2
FOO
say <<'BAR', <<'BAZ', ";
bar1
bar2
BAR
baz1
baz2
BAZ
baz";
DOCUMENT

	elements_wrap (
		'PPIx::Augment::Utils::Statement',
		($document->children)[ 0 ],
	);

	my ($wrap) = ppix_find $document, where { it_is 'PPIx::Augment::Utils::Statement' };

	it "should find wrap element"
		=> got    => $wrap
		=> expect => expect_element ('PPIx::Augment::Utils::Statement')
		;

	it "should wrap heredocs into extended element"
		=> got    => $document->serialize
		=> expect => $origin
		;
}

had_no_warnings;

done_testing;

package
	PPIx::Augment::Utils::Statement {
	use parent qw[ PPI::Statement ];
}
