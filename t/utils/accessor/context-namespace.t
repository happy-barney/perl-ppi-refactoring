
use v5.14;
use warnings;

use require::relative q (../../test-helper.pl);

assume_ppi q (augmentation should )
	=> document => augmented_document (q (package foo))
	=> where    => where { its_parent { it_is_document } }
	=> expect   => expect_nodeset (
		expect_element (PPI::Statement::        => (
			expect_element (PPI::Token::Word::      => q (foo)   ),
		expect_element (PPI::Token::Structure:: => q (;)     ),
		expect_element (PPI::Token::Whitespace::             ),
		expect_element (PPI::Statement::                     ),
		expect_element (PPI::Token::Word::      => q (bar)   ),
		expect_element (PPI::Token::Structure:: => q (;)     ),
	);

not 1 and assume_ppi q (context_namespace should return explicit package name for package declaration)
	=> document => augmented_document (q (foo; package Foo; bar;))
	=> where    => where { 1 }
	=> expect   => expect_nodeset (
		expect_element (PPI::Statement::                     ) & expect_context_namespace (undef),
		expect_element (PPI::Token::Word::      => q (foo)     ) & expect_context_namespace (undef),
		expect_element (PPI::Token::Structure:: => q (;)       ) & expect_context_namespace (undef),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (undef),
		expect_element (PPIx::Augment::Context::Package::    ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Statement::Package::            ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (package) ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (Foo)     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Structure:: => q (;)       ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Statement::                     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (bar)     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Structure:: => q (;)       ) & expect_context_namespace (q (Foo)),
	);

not 1 and assume_ppi q (context_namespace should return explicit package name for nested package block)
	=> document => augmented_document (q (foo; package Foo; bar; package Bar { baz } bar2))
	=> where    => where { 1 }
	=> expect   => expect_nodeset (
		expect_element (PPI::Statement::                     ) & expect_context_namespace (undef),
		expect_element (PPI::Token::Word::      => q (foo)     ) & expect_context_namespace (undef),
		expect_element (PPI::Token::Structure:: => q (;)       ) & expect_context_namespace (undef),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (undef),
		expect_element (PPIx::Augment::Context::Package::    ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Statement::Package::            ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (package) ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (Foo)     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Structure:: => q (;)       ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Statement::                     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (bar)     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Structure:: => q (;)       ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Foo)),

		expect_element (PPIx::Augment::Context::Package::    ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Statement::Package::            ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Word::      => q (package) ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Word::      => q (Bar)     ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Structure::Block::              ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Structure:: => q ({)       ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Statement::                     ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Word::      => q (baz)     ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Bar)),
		expect_element (PPI::Token::Structure:: => q (})       ) & expect_context_namespace (q (Bar)),

		expect_element (PPI::Token::Whitespace::             ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Statement::                     ) & expect_context_namespace (q (Foo)),
		expect_element (PPI::Token::Word::      => q (bar2)    ) & expect_context_namespace (q (Foo)),
	);

had_no_warnings;
done_testing;

