
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

plan tests => 3;

check_ppi "should find all package statements"
	=> where    => where { it_is_package_definition }
	=> document => <<'		DOCUMENT'
		package Foo;
		package Bar { package Bar::Bar; package Bar::Baz v1.0.0 {} }
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Bar'),
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Bar::Baz'),
	);

check_ppi "should find name package statements"
	=> where    => where { it_is_package_definition 'Bar' }
	=> document => <<'		DOCUMENT'
		package Foo;
		package Bar { package Bar::Bar; package Bar::Baz v1.0.0 {} }
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Bar'),
	);

had_no_warnings;

done_testing;
