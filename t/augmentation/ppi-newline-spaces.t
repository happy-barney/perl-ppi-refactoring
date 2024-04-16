
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Augment::Augmentation::PPI::Newline_Spaces;

testing_augmentation { PPIx::Augment::Augmentation::PPI::Newline_Spaces:: };

my $element = PPIx::Augment::Utils::_build_element (
	PPI::Document::,
	build_token_whitespace (qq (\n)),
	build_token_whitespace (qq (\t\t)),
	build_token_whitespace (qq ( \n)),
	build_token_whitespace (qq (\n\n\t\t)),
);

assume_augmentation q (collected elements)
	=> element        => $element
	=> expect_analyze => [
		expect_element (PPI::Token::Whitespace::, qq ( \n)),
		expect_element (PPI::Token::Whitespace::, qq (\n\n\t\t)),
	]
	=> expect_augment => 2
	=> expect_result  => expect_element (PPI::Document::, (
		expect_element (PPI::Token::Whitespace::, qq (\n)),
		expect_element (PPI::Token::Whitespace::, qq (\t\t)),
		expect_element (PPI::Token::Whitespace::, q  ( )),
		expect_element (PPI::Token::Whitespace::, qq (\n)),
		expect_element (PPI::Token::Whitespace::, qq (\n)),
		expect_element (PPI::Token::Whitespace::, qq (\n)),
		expect_element (PPI::Token::Whitespace::, qq (\t\t)),
	));

had_no_warnings;
done_testing;
