
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use Perl::Critic::Policy::BuiltinFunctions::RequireBlockGrep;
use PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::RequireBlockGrep;

testing_refactoring { PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::RequireBlockGrep:: };

assume_refactoring q (should repair regex condition)
	=> document       => q (grep /foo/, @list)
	=> expect_analyze => [
		expect_element (PPI::Token::Word::, q (grep)),
	]
	=> expect_augment => -1
;

ppi_dump ppi_document q (grep /foo/, @list);


fail;

had_no_warnings;
done_testing;
