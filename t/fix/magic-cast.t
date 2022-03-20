
use v5.14;
use warnings;

use require::relative "test-helper-fix.pl";

plan tests => 8;

note <<'';
	When treating multiple deferences (though rare) PPI (v1.272) mistakenly
	recognizes pair of dollar signs as single magic token

testing_ppi_fix 'PPIx::Augment::Fix::Magic_Cast';

behaves_like_ppi_fix 'should fix $$$foo'
	=> document     => '$$$foo'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Symbol'     => '$foo'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Symbol'     => '$foo'),
		)),
	));

behaves_like_ppi_fix 'should fix $$ $foo'
	=> document     => '$$ $foo'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Symbol'     => '$foo'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Whitespace' => ' '),
			expect_element ('PPI::Token::Symbol'     => '$foo'),
		)),
	));

behaves_like_ppi_fix 'should fix $$$$$$foo'
	=> document     => '$$$$$$foo'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Symbol'     => '$foo'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Symbol'     => '$foo'),
		)),
	));

behaves_like_ppi_fix 'should fix $$${}'
	=> document     => '$$${}'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Structure::Block'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Token::Cast'       => '$'),
			expect_element ('PPI::Structure::Block'),
		)),
	));

behaves_like_ppi_fix 'should not fix $$@{}'
	=> document     => '$$@{}'
	=> expect_ppi   => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Cast'       => '@'),
			expect_element ('PPI::Structure::Block'),
		)),
	))
	=> expect_fixed => expect_element ('PPI::Document' => (
		expect_element ('PPI::Statement' => (
			expect_element ('PPI::Token::Magic'      => '$$'),
			expect_element ('PPI::Token::Cast'       => '@'),
			expect_element ('PPI::Structure::Block'),
		)),
	));

ppix_augment_should_execute_ppi_fix;

had_no_warnings;

done_testing;
