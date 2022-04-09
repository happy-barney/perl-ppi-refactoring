
use v5.14;
use warnings;

use require::relative "../test-helper.pl";

plan tests => 3;

check_ppi "should find all package declarations (package without block)"
	=> where    => where { it_is_package_declaration }
	=> document => <<'		DOCUMENT'
		package Foo;
		package Bar { package Bar::Bar v1.0.0; package Bar::Baz {} }
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Foo'),
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Bar::Bar'),
	);

check_ppi "should find named package declarations"
	=> where    => where { it_is_package_declaration 'Foo' }
	=> document => <<'		DOCUMENT'
		package Foo;
		package Bar { package Bar::Bar v1.0.0; package Bar::Baz {} }
		DOCUMENT
	=> expect => expect_nodeset (
		expect_element ('PPI::Statement::Package') & methods (namespace => 'Foo'),
	);

had_no_warnings;

done_testing;
