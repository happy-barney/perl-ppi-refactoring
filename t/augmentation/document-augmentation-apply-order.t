
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

use PPIx::Augment::Document;

act { [ PPIx::Augment::Document->augmentation_apply_order (@{ $_[0] }) ] }
	q (augmentations)
	;

assume q (it should return augmentations without requirements in definition order)
	=> with_augmentations => [
		q (Augmenation::Simple),
		q (Augmenation::Base),
	],
	=> expect             => [
		q (Augmenation::Simple),
		q (Augmenation::Base),
	];

assume q (it should deduplicate redundant augmentations)
	=> with_augmentations => [
		q (Augmenation::Simple),
		q (Augmenation::Base),
		q (Augmenation::Base),
		q (Augmenation::Simple),
	],
	=> expect             => [
		q (Augmenation::Simple),
		q (Augmenation::Base),
	];

assume q (it should build dependency order)
	=> with_augmentations => [
		q (Augmenation::Foo),
		q (Augmenation::Baz),
		q (Augmenation::Bar),
	],
	=> expect             => [
		q (Augmenation::Base),
		q (Augmenation::Bar),
		q (Augmenation::Foo),
		q (Augmenation::Baz),
	];

assume q (it should detect dependency cycle)
	=> with_augmentations => [
		q (Augmenation::Cycle),
	],
	=> throws             => expect_re (qr (cycle detected))
	;

had_no_warnings;
done_testing;

package Augmenation::Foo {
	use constant requires => (
		q (Augmenation::Bar),
	);
}

package Augmenation::Bar {
	use constant requires => (
		q (Augmenation::Base),
	);
}

package Augmenation::Base {
	use constant requires => (
	);
}

package Augmenation::Simple {
	use constant requires => (
	);
}

package Augmenation::Baz {
	use constant requires => (
		q (Augmenation::Base),
	);
}

package Augmenation::Cycle {
	use constant requires => (
		q (Augmenation::Cycle::One),
	);
}

package Augmenation::Cycle::One {
	use constant requires => (
		q (Augmenation::Cycle::Two),
	);
}

package Augmenation::Cycle::Two {
	use constant requires => (
		q (Augmenation::Cycle::One),
	);
}

