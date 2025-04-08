
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_augmentation { q (PPIx::Augment::Augmentation::Repair::PPI::Newline_Spaces) };

assume_augmentation q (

# TODO: should have actual PPI document

my $element = PPIx::Augment::Utils::_build_element (
	PPI::Document::,
	create_token_whitespace (qq (\n)),
	create_token_whitespace (qq (\t\t)),
	create_token_whitespace (qq ( \n)),
	create_token_whitespace (qq (\n\n\t\t)),
);

assume_augmentation q (collected elements)
	=> element        => $element
	=> expect_analyze => [
		expect_ppi_token_whitespace, qq ( \n)),
		expect_ppi_token_whitespace, qq (\n\n\t\t)),
	]
	=> expect_augment => 2
	=> expect_result  => expect_ppi_document, (
		expect_ppi_token_whitespace, qq (\n)),
		expect_ppi_token_whitespace, qq (\t\t)),
		expect_ppi_token_whitespace, q  ( )),
		expect_ppi_token_whitespace, qq (\n)),
		expect_ppi_token_whitespace, qq (\n)),
		expect_ppi_token_whitespace, qq (\n)),

		expect_ppi_token_whitespace, qq (\t\t)),
		

	));

had_no_warnings;
done_testing;
