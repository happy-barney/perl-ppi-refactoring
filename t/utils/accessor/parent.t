
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

my $document = ppi_document q (1 2);
my ($one, $two) = @{ $document->find (where { it_is_token_number }) };

assume q (it should work with current element)
	=> got    { local $_ = $one; parent }
	=> expect => expect_element (PPI::Statement:: => q (1 2))
	;

assume q (it should work with effective element)
	=> got    { parent $two }
	=> expect => expect_element (PPI::Statement:: => q (1 2))
	;

assume q (it should return no element when element doesn't have a parent)
	=> got    { parent $document }
	=> expect => expect_no_element
	;

had_no_warnings;
done_testing;
