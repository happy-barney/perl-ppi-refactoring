
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

use Perl::Critic::Policy::BuiltinFunctions::ProhibitReverseSortBlock;
use PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::ProhibitReverseSortBlock;

testing_refactoring { PPIx::Refactoring::Repair::Critic::Policy::BuiltinFunctions::ProhibitReverseSortBlock:: };

assume_refactoring q (should repair sort with reverse condition)
	=> document       => q (sort { $hash{$b} <=> $hash{$a} } keys %hash)
	=> expect_analyze => [
		expect_element (PPI::Token::Word::, q (sort)),
	]
	=> expect_result  => q (reverse sort { $hash{$a} <=> $hash{$b} } keys %hash)
	;

assume_refactoring q (should repair sort with complex condition)
	=> document       => q (sort { $b cmp $a || $hash{$b} <=> $hash{$a} } keys %hash)
	=> expect_analyze => [
		expect_element (PPI::Token::Word::, q (sort)),
	]
	=> expect_result  => q (reverse sort { $a cmp $b || $hash{$a} <=> $hash{$b} } keys %hash)
	;

had_no_warnings;
done_testing;
