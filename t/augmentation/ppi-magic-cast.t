
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

note <<'';
    As of v1.278 PPI mistakenly recognizes pair of dollar signs,
    when used as multiple scalar dereferences, as single magic token

use PPIx::Augment::Augmentation::PPI::Magic_Cast;

testing_augmentation { PPIx::Augment::Augmentation::PPI::Magic_Cast:: };

assume_augmentation q (should fix '$$$foo')
	=> document        => q ($$$foo)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Magic::     => q ($$), { column_number => 1 }),
			expect_element (PPI::Token::Symbol::    => q ($foo)),
		)),
	)
	=> expect_analyze => [
		expect_element (PPI::Token::Magic::         => q ($$), { column_number => 1 }),
	]
	=> expect_augment => expect_true,
	=> expect_result  => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Symbol::    => q ($foo)),
		)),
	);

assume_augmentation q (should fix '@$$$foo')
	=> document        => q (@$$$foo)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Cast::      => q (@)),
			expect_element (PPI::Token::Magic::     => q ($$), { column_number => 2 }),
			expect_element (PPI::Token::Symbol::    => q ($foo)),
		)),
	)
	=> expect_analyze  => [
		expect_element (PPI::Token::Magic::         => q ($$), { column_number => 2 }),
	]
	=> expect_augment => expect_true,
	=> expect_result   => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Cast::      => q (@)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Symbol::    => q ($foo)),
		)),
	);

assume_augmentation q (should fix '$$ $foo' - whitespace doesn't matter)
	=> document        => q ($$ $foo)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::             => (
			expect_element (PPI::Token::Magic::      => q ($$), { column_number => 1 }),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Symbol::     => q ($foo)),
		)),
	)
	=> expect_analyze  => [
		expect_element (PPI::Token::Magic::          => q ($$), { column_number => 1 }),
	]
	=> expect_augment  => expect_true,
	=> expect_result   => expect_document (
		expect_element (PPI::Statement:: => (
			expect_element (PPI::Token::Cast::       => q ($)),
			expect_element (PPI::Token::Cast::       => q ($)),
			expect_element (PPI::Token::Whitespace:: => q ( )),
			expect_element (PPI::Token::Symbol::     => q ($foo)),
		)),
	);

assume_augmentation q (should fix '$$$$$$foo' - soo many dereferences)
	=> document        => q ($$$$$$foo)
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Magic::     => q ($$), { column_number => 1 }),
			expect_element (PPI::Token::Magic::     => q ($$), { column_number => 3 }),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Symbol::    => q ($foo)),
		)),
	)
	=> expect_analyze  => [
		expect_element (PPI::Token::Magic::         => q ($$), { column_number => 1 }),
		expect_element (PPI::Token::Magic::         => q ($$), { column_number => 3 }),
	]
	=> expect_augment  => expect_true,
	=> expect_result   => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Symbol::    => q ($foo)),
		)),
	);

assume_augmentation q (should fix '$${}')
	=> document        => q ($${})
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Magic::     => q ($$), { column_number => 1 }),
			expect_element (PPI::Structure::Subscript::),
		)),
	)
	=> expect_analyze  => [
		expect_element (PPI::Token::Magic::         => q ($$), { column_number => 1 }),
	],
	=> expect_augment  => expect_true,
	=> expect_result   => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Cast::          => q ($)),
			expect_element (PPI::Token::Cast::          => q ($)),
			expect_element (PPI::Structure::Block::),
		)),
	);

assume_augmentation q (should fix '$$${}')
	=> document        => q ($$${})
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Magic::     => q ($$), { column_number => 1 }),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Structure::Block::),
		)),
	)
	=> expect_analyze  => [
		expect_element (PPI::Token::Magic::         => q ($$), { column_number => 1 }),
	]
	=> expect_augment  => expect_true,
	=> expect_result   => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Token::Cast::      => q ($)),
			expect_element (PPI::Structure::Block::),
		)),
	);

assume_augmentation q (shouldn't fix $$@{} - '$$' are not scalar dereferences)
	=> document        => q ($$@{})
	=> expect_document => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Magic::     => q ($$)),
			expect_element (PPI::Token::Cast::      => q (@)),
			expect_element (PPI::Structure::Block::),
		)),
	)
	=> expect_analyze  => [
	]
	=> expect_augment  => expect_false,
	=> expect_result   => expect_document (
		expect_element (PPI::Statement::            => (
			expect_element (PPI::Token::Magic::     => q ($$)),
			expect_element (PPI::Token::Cast::      => q (@)),
			expect_element (PPI::Structure::Block::),
		)),
	);

had_no_warnings;
done_testing;

