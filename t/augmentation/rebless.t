
use require::relative "test-helper-augmentation.pl";

note <<'';
	Rebless PPI elements into its PPIx::Augment counterpart

plan tests => 3;

testing_augmentation 'PPIx::Augment::Augmentation::Rebless';

behaves_like_augmentation "it should rebless document"
	=> document         => \ ''
	=> expect_ppi       => expect_element ('PPI::Document')
	=> expect_augmented => expect_element ('PPIx::Augment::Document')
	;

had_no_warnings;

done_testing;
