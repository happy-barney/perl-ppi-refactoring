
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_word_list @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
use Foo qw (1 2 3);
qw <x y z>;
END_OF_DOCUMENT

assume_ppi q (should match any instance of PPI::Token::QuoteLike::Words::)
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::QuoteLike::Words:: => q (qw (1 2 3))),
		expect_element (PPI::Token::QuoteLike::Words:: => q (qw <x y z>)),
	);

assume_ppi q (should accept additional conditions)
	=> conditions => [ qr (\d)x ]
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::QuoteLike::Words:: => q (qw (1 2 3))),
	);

had_no_warnings;
done_testing;

