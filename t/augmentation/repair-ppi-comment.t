
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use PPIx::Augment::Augmentation::Repair::PPI::Comment;

testing_augmentation { PPIx::Augment::Augmentation::Repair::PPI::Comment:: };
arrange_document     { <<'END_OF_DOCUMENT' };
#!perl
    # comment with indent
END_OF_DOCUMENT

assume_augmentation q (should repair comments with leading/trailing whitespaces)
	=> expect_analyze => [
		expect_element (PPI::Token::Comment::,    qq (#!perl\n)),
		expect_element (PPI::Token::Comment::,    qq (    # comment with indent\n)),
		expect_element (PPI::Token::Comment::,    qq (    # comment with indent\n)),
	]
	=> expect_augment => 3
	=> expect_result  => expect_element (PPI::Document::, (
		expect_element (PPI::Token::Comment::,    qq (#!perl)),
		expect_element (PPI::Token::Whitespace::, qq (\n)),
		expect_element (PPI::Token::Whitespace::, q  (    )),
		expect_element (PPI::Token::Comment::,    qq (# comment with indent)),
		expect_element (PPI::Token::Whitespace::, qq (\n)),
	))
	;
done_testing;
