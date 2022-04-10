
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

check_ppi "context_namespace should return only explicit package name"
	=> document => augmented_document ('foo; bar;')
	=> where    => where { 1 }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Statement'                     ),
		expect_element ('PPI::Token::Word'      => 'foo'     ),
		expect_element ('PPI::Token::Structure' => ';'       ),
		expect_element ('PPI::Token::Whitespace'             ),
		expect_element ('PPI::Statement'                     ),
		expect_element ('PPI::Token::Word'      => 'bar'     ),
		expect_element ('PPI::Token::Structure' => ';'       ),
	);

check_ppi "context_namespace should return explicit package name for package declaration"
	=> document => augmented_document ('foo; package Foo; bar;')
	=> where    => where { 1 }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Statement'                     ) & expect_context_namespace (undef),
		expect_element ('PPI::Token::Word'      => 'foo'     ) & expect_context_namespace (undef),
		expect_element ('PPI::Token::Structure' => ';'       ) & expect_context_namespace (undef),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace (undef),
		expect_element ('PPIx::Augment::Context::Package'    ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Statement::Package'            ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'package' ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'Foo'     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Structure' => ';'       ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Statement'                     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'bar'     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Structure' => ';'       ) & expect_context_namespace ('Foo'),
	);

check_ppi "context_namespace should return explicit package name for nested package block"
	=> document => augmented_document ('foo; package Foo; bar; package Bar { baz } bar2')
	=> where    => where { 1 }
	=> expect   => expect_nodeset (
		expect_element ('PPI::Statement'                     ) & expect_context_namespace (undef),
		expect_element ('PPI::Token::Word'      => 'foo'     ) & expect_context_namespace (undef),
		expect_element ('PPI::Token::Structure' => ';'       ) & expect_context_namespace (undef),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace (undef),
		expect_element ('PPIx::Augment::Context::Package'    ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Statement::Package'            ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'package' ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'Foo'     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Structure' => ';'       ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Statement'                     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'bar'     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Structure' => ';'       ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Foo'),

		expect_element ('PPIx::Augment::Context::Package'    ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Statement::Package'            ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Word'      => 'package' ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Word'      => 'Bar'     ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Structure::Block'              ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Structure' => '{'       ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Statement'                     ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Word'      => 'baz'     ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Bar'),
		expect_element ('PPI::Token::Structure' => '}'       ) & expect_context_namespace ('Bar'),

		expect_element ('PPI::Token::Whitespace'             ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Statement'                     ) & expect_context_namespace ('Foo'),
		expect_element ('PPI::Token::Word'      => 'bar2'    ) & expect_context_namespace ('Foo'),
	);

had_no_warnings;

done_testing;

