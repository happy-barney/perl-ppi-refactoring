
use v5.14;
use warnings;

use require::relative "test-helper-fix.pl";

note <<'';
	PPI doesn't recognize new octal format 0o000 yet (v1.272)

plan tests => 4;

testing_ppi_fix 'PPIx::Augment::Fix::New_Octal_Numbers';

behaves_like_ppi_fix "recognize new octal syntax as Number::Octal"
	=> document     => \ '0o_123'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Number'     => '0'),
			expect_element ('PPI::Token::Word'       => 'o_123'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Number::Octal' => '0o_123'),
		)),
	));

ppix_augment_should_execute_ppi_fix;

had_no_warnings;

done_testing;
