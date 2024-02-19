
use v5.14;
use warnings;

use require::relative "test-helper-traversal.pl";

it "should not execute code when current is not an instance"
	=> got    => do {
		local $_ = '';
		its_sprevious_sibling { fail "should not be executed" }
	}
	=> expect => expect_ppi_false
	;

it "should not execute code when current is not an instance"
	=> got    => do {
		local $_ = '';
		its_sprevious_sibling { fail "should not be executed" }
	}
	=> expect => expect_ppi_false
	;

it "should not execute code when current is not an PPI::Node instance"
	=> got    => do {
		local $_ = bless {}, 'PPI::Element';
		its_sprevious_sibling { fail "should not be executed" }
	}
	=> expect => expect_ppi_false
	;

it "should not execute code when there is no sibling"
	=> got    => do {
		local $_ = PPI::Token::Word->new ();
		its_sprevious_sibling { fail "should not be executed" }
	}
	=> expect => expect_ppi_false
	;

it "should execute code on preceding significant sibling"
	=> got    => do {
		my $document = document "{1,2}";
		local ($_) = ppix_find $document, where { current->content eq '2' };
		fail "expected element not found" and return
			unless $_;
		its_sprevious_sibling { current_content }
	}
	=> expect => ","
	;

had_no_warnings;

done_testing;
