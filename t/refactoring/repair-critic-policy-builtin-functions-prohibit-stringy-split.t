
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use Perl::Critic::Policy::BuiltinFunctions::ProhibitStringySplit;
use PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::ProhibitStringySplit;

testing_refactoring { PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::ProhibitStringySplit:: };

assume_refactoring q (should repair double quoted string literal)
	=> document       => q (split("\n", $data))
	=> expect_analyze => [
		expect_element (PPI::Token::Word::, q (split)),
	]
	=> expect_result  => q (split(qr"\n", $data))
	;

assume_refactoring q (should repair single quoted string literal)
	=> document       => q (split ':', $data)
	=> expect_analyze => [
		expect_element (PPI::Token::Word::, q (split)),
	]
	=> expect_result  => q (split qr':', $data)
	;

assume_refactoring q (should repair string literal containing '/')
	=> document       => q (split '/', $data)
	=> expect_analyze => [
		expect_element (PPI::Token::Word::, q (split)),
	]
	=> expect_result  => q (split qr'/', $data)
	;

had_no_warnings;
done_testing;
