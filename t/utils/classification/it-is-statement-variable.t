
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_statement_variable @_ };
arrange_document       { <<'END_OF_DOCUMENT' };
my $foo = 1;
my ($foo, $bar) = (1, 2);
our $foo = 1;
state $foo;
local $foo;
local $foo = 1;
END_OF_DOCUMENT

assume_ppi q (should match instance of PPI::Statement::Variable)
	=> expect     => expect_nodeset (
		expect_element (PPI::Statement::Variable:: => q (my $foo = 1;)),
		expect_element (PPI::Statement::Variable:: => q (my ($foo, $bar) = (1, 2);)),
		expect_element (PPI::Statement::Variable:: => q (our $foo = 1;)),
		expect_element (PPI::Statement::Variable:: => q (state $foo;)),
		expect_element (PPI::Statement::Variable:: => q (local $foo;)),
		expect_element (PPI::Statement::Variable:: => q (local $foo = 1;)),
	);

had_no_warnings;
done_testing;

