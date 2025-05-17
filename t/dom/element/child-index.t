
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

use PPIx::Augment::DOM::Element;

my $document = ppi_document (fixture (q (multiple-packages.pl)));

my ($found) = @{ $document->find (sub { $_[1]->content eq q (Foo) }) };
my $parentless = PPI::Token::Word::->new (q (foo));

assume q (child_index () should return element's index in parent's list of children)
	=> got    { $found->PPIx::Augment::DOM::Element::child_index }
	=> expect => 2
	;

assume q (child_index () should return `undef` when element has no parent)
	=> got    { $parentless->PPIx::Augment::DOM::Element::child_index }
	=> expect => undef
	;

had_no_warnings;
done_testing;

