
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";
use require::relative "test-helper-traversal.pl";

my $document = document (<<'DOCUMENT');
foo;
package bar { baz };
{
	foo2;
}
DOCUMENT

check_ppi "ppi_false () should allow descend into children"
	=> document => $document
	=> expect   => expect_nodeset (
		expect_element ('PPI::Token::Word', 'foo'),
		expect_element ('PPI::Token::Word', 'package'),
		expect_element ('PPI::Token::Word', 'bar'),
		expect_element ('PPI::Token::Word', 'baz'),
		expect_element ('PPI::Token::Word', 'foo2'),
	)
	=> where    => sub {
		return ppi_true if $_[1]->isa ('PPI::Token::Word');
		return ppi_false;
	};

check_ppi "ppi_false_dont_descent () should prohibit descend into children"
	=> document => $document
	=> expect   => expect_nodeset (
		expect_element ('PPI::Token::Word', 'foo'),
		expect_element ('PPI::Token::Word', 'foo2'),
	)
	=> where    => sub {
		return ppi_true if $_[1]->isa ('PPI::Token::Word');
		return ppi_false_dont_descent if $_[1]->isa ('PPI::Statement::Package');
		return ppi_false;
	};

subtest "expect_ppi_true()" => sub {
	my $expect = expect_ppi_true;

	ok "should pass for ppi_true()"
		=> got    => eq_deeply (ppi_true, $expect)
		;

	nok "should fail for ppi_false()"
		=> got    => eq_deeply (ppi_false, $expect)
		;

	nok "should fail for ppi_false_dont_descent()"
		=> got    => eq_deeply (ppi_false_dont_descent, $expect)
		;
};

subtest "expect_ppi_false()" => sub {
	my $expect = expect_ppi_false;

	nok "should fail for ppi_true()"
		=> got    => eq_deeply (ppi_true, $expect)
		;

	ok  "should pass for ppi_false()"
		=> got    => eq_deeply (ppi_false, $expect)
		;

	nok "should fail for ppi_false_dont_descent()"
		=> got    => eq_deeply (ppi_false_dont_descent, $expect)
		;
};

subtest "expect_ppi_false_do_not_descend()" => sub {
	my $expect = expect_ppi_false_do_not_descend;

	nok "should fail for ppi_true()"
		=> got    => eq_deeply (ppi_true, $expect)
		;

	nok "should fail for ppi_false()"
		=> got    => eq_deeply (ppi_false, $expect)
		;

	ok  "should pass for ppi_false_dont_descent()"
		=> got    => eq_deeply (ppi_false_dont_descent, $expect)
		;
};

had_no_warnings;

done_testing;
