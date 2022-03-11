
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

plan tests => 2;

check_ppi "should find all package statements"
	=> where    => where { it_is_statement_package }
	=> document => <<'		DOCUMENT'
		package Foo;
		package Bar { }
		package Foo;
		DOCUMENT
	=> expect => expect_element ('PPIx::Augment::Nodeset' => (
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Foo'),
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Bar'),
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Foo'),
	)),
	;

had_no_warnings;

done_testing;
