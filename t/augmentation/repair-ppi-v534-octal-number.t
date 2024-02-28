
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

note <<'';
	As of v1.277 PPI doesn't recognize new octal format 0o0 yet

use PPIx::Augment::Augmentation::Repair::PPI::V534_Octal_Number;

testing_augmentation { PPIx::Augment::Augmentation::Repair::PPI::V534_Octal_Number:: };

assume_augmentation q (recognize new octal syntax)
	=> document         => q (0o_123)
	=> expect_before    => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Number::     => q (0)),
			expect_element (PPI::Token::Word::       => q (o_123)),
		)),
	))
	=> expect_augmented => expect_element (PPI::Document:: => (
		expect_element (PPI::Statement:: => (
			expect_element (PPIx::Augment::Token::Number::Octal::v534:: => q (0o_123)),
		)),
	));

had_no_warnings;
done_testing;
