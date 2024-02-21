
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { & it_is_token_whitespace };

subtest q (basic classification) => sub {
	my $element = PPI::Token::Whitespace::->new (q ( ));

	assume_classification q (should accept instance of PPI::Token::Whitespace::)
		=> element    => $element
		=> expect     => & expect_ppi_include
		;

	assume_classification q (should accept when content equals)
		=> element    => $element
		=> conditions => [ q ( ) ]
		=> expect     => & expect_ppi_include
		;

	assume_classification q (should match when content matches regex)
		=> element    => $element
		=> conditions => [ qr (^[ ]$) ]
		=> expect     => & expect_ppi_include
		;

	assume_classification q (should reject when value doesn't equal)
		=> element    => $element
		=> conditions => [ q (..) ]
		=> expect     => & expect_ppi_exclude
		;
	assume_classification q (should reject instance of other class)
		=> element    => PPI::Token::Comment::->new (q ( ))
		=> expect     => & expect_ppi_exclude
		;
};

subtest q (PPI behaviour) => sub {
	arrange_document { <<'END_OF_DOCUMENT' };
package Foo     {
	sub foo_bar {

		1
    
	};
}
END_OF_DOCUMENT

	assume_ppi q (should include all whitespaces)
		=> expect     => expect_nodeset (
			expect_element (PPI::Token::Whitespace::, q  ( )),
			expect_element (PPI::Token::Whitespace::, q  (     )),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (\t)),
			expect_element (PPI::Token::Whitespace::, q  ( )),
			expect_element (PPI::Token::Whitespace::, q  ( )),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (\n\t\t)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (    \n\t)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
		);

	assume_ppi q (should accept additional conditions)
		=> conditions => [ qr (\n) ]
		=> expect   => expect_nodeset (
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (\n\t\t)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (    \n\t)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
			expect_element (PPI::Token::Whitespace::, qq (\n)),
		);
};

had_no_warnings;
done_testing;
