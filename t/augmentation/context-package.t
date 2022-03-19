
use v5.14;
use warnings;

use require::relative "test-helper-augmentation.pl";

note <<'';
	Wrap elements belonging to package into single element

plan tests => 3;

testing_augmentation 'PPIx::Augment::Augmentation::Context::Package';

my $complex_document = <<'DOCUMENT';
package Foo;
foo; bar;
package Bar;
foo; bar;
package Baz { baz }
foo2;
DOCUMENT

sub is_Foo () { methods (context_namespace => 'Foo') }
sub is_Bar () { methods (context_namespace => 'Bar') }
sub is_Baz () { methods (namespace => 'Baz') }

behaves_like_augmentation "it should rebless document"
	=> document         => \ $complex_document,
	=> expect_ppi       => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement::Package' => (
			expect_element ('PPI::Token::Word' => 'package'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Word' => 'Foo'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'foo'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'bar'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement::Package' => (
			expect_element ('PPI::Token::Word' => 'package'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Word' => 'Bar'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'foo'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'bar'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement::Package' => (
			expect_element ('PPI::Token::Word' => 'package'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Token::Word' => 'Baz'),
			expect_element ('PPI::Token::Whitespace'),
			expect_element ('PPI::Structure::Block'),
		)),
		expect_element ('PPI::Token::Whitespace'),
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Word' => 'foo2'),
			expect_element ('PPI::Token::Structure' => ';'),
		)),
		expect_element ('PPI::Token::Whitespace'),
	))
	=> expect_augmented => expect_element ('PPI::Document' => (
		is_Foo & expect_element ('PPIx::Augment::Context::Package' => (
			is_Foo & expect_element ('PPI::Statement::Package' => (
				is_Foo & expect_element ('PPI::Token::Word' => 'package'),
				is_Foo & expect_element ('PPI::Token::Whitespace'),
				is_Foo & expect_element ('PPI::Token::Word' => 'Foo'),
				is_Foo & expect_element ('PPI::Token::Structure' => ';'),
			)),
			is_Foo & expect_element ('PPI::Token::Whitespace'),
			is_Foo & expect_element ('PPI::Statement' => (
				is_Foo & expect_element ('PPI::Token::Word' => 'foo'),
				is_Foo & expect_element ('PPI::Token::Structure' => ';'),
			)),
			is_Foo & expect_element ('PPI::Token::Whitespace'),
			is_Foo & expect_element ('PPI::Statement' => (
				is_Foo & expect_element ('PPI::Token::Word' => 'bar'),
				is_Foo & expect_element ('PPI::Token::Structure' => ';'),
			)),
			is_Foo & expect_element ('PPI::Token::Whitespace'),
		)),
		is_Bar & expect_element ('PPIx::Augment::Context::Package' => (
			is_Bar & expect_element ('PPI::Statement::Package'),
			is_Bar & expect_element ('PPI::Token::Whitespace'),
			is_Bar & expect_element ('PPI::Statement'),
			is_Bar & expect_element ('PPI::Token::Whitespace'),
			is_Bar & expect_element ('PPI::Statement'),
			is_Bar & expect_element ('PPI::Token::Whitespace'),
			is_Baz & expect_element ('PPIx::Augment::Context::Package'),
			is_Bar & expect_element ('PPI::Token::Whitespace'),
			is_Bar & expect_element ('PPI::Statement'),
			is_Bar & expect_element ('PPI::Token::Whitespace'),
		)),
	))
	;

had_no_warnings;

done_testing;
