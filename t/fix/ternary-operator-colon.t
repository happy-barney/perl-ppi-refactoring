
use v5.14;
use warnings;

use require::relative "../test-helper-augmentation.pl";

note <<'';
	When method is called just by its name in then-clause of conditional operator
	PPI fails to recognize it as a WORD followed by COLON and reports LABEL instead

plan tests => 6;

local *ppix_augmentation
	= testing_ppix_augmentation 'PPIx::Augment::Fix::Ternary_Operator_Colon'
	;

behaves_like_ppix_augmentation "fix should preserve whitespace before colon"
	=> document     => '$foo ? foo : bar'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol'     => '$foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => '?'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Label'      => 'foo :'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'bar'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol'     => '$foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => '?'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => ':'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'bar'),
		)),
	));

behaves_like_ppix_augmentation "fix shouldn't generate zero-length whitespace"
	=> document     => '$foo ? foo: bar'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol'     => '$foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => '?'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Label'      => 'foo:'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'bar'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol'     => '$foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => '?'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'foo'),
			expect_element ('PPI::Token::Operator'   => ':'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'bar'),
		)),
	));

behaves_like_ppix_augmentation "fix should recognize method call"
	=> document     => '$foo ? FOO->foo : BAR->bar'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol'     => '$foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => '?'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'FOO'),
			expect_element ('PPI::Token::Operator'   => '->'),
			expect_element ('PPI::Token::Label'      => 'foo :'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'BAR'),
			expect_element ('PPI::Token::Operator'   => '->'),
			expect_element ('PPI::Token::Word'       => 'bar'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Symbol'     => '$foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => '?'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'FOO'),
			expect_element ('PPI::Token::Operator'   => '->'),
			expect_element ('PPI::Token::Word'       => 'foo'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Operator'   => ':'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Word'       => 'BAR'),
			expect_element ('PPI::Token::Operator'   => '->'),
			expect_element ('PPI::Token::Word'       => 'bar'),
		)),
	));

ppix_augment_should_execute_ppix_augmentation;

had_no_warnings;

done_testing;
