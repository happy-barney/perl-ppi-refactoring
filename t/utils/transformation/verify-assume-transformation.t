
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_transformation { $_->remove for @_ };

assume_transformation q (should use transformation under test)
	=> document       => q (1; 2; 3)
	=> where          => where { it_is_token_number }
	=> expect         => q (; ; )
	;

assume_transformation q (should favour transformation via arguments)
	=> document       => q (1; 2; 3)
	=> where          => where { it_is_token_number }
	=> transformation => \ &increment
	=> expect         => q (2; 3; 4)
	;

assume_transformation q (should recognize transformation by function name)
	=> document       => q (1; 2; 3)
	=> where          => where { it_is_token_number }
	=> transformation => q (increment)
	=> expect         => q (2; 3; 4)
	;

assume_transformation q (should recognize transformation with arguments)
	=> document       => q (1; 2; 3)
	=> where          => where { it_is_token_number }
	=> transformation => [ increment_by => 10 ]
	=> expect         => q (11; 12; 13)
	;

assume_transformation q (should apply argument transformation 'arguments')
	=> document       => q (1; 2; 3)
	=> where          => where { it_is_token_number }
	=> arguments      => sub { $_[0], $_[2] }
	=> expect         => q (; 2; )
	;

assume_transformation q (first found element should become current element)
	=> document       => q (1; 2; 3)
	=> where          => where { it_is_token_number }
	=> transformation => sub { $_->remove }
	=> expect         => q (; 2; 3)
	;

assume_transformation q (should not execute transformation when no element is found)
	=> document       => q (1; 2; 3)
	=> where          => where { 0 }
	=> transformation => sub { fail q ('no element found' transformation shouldn't be executed) }
	=> expect         => q (1; 2; 3)
	;

had_no_warnings;
done_testing;

sub increment {
	$_->set_content ($_->literal + 1) for @_;
}

sub increment_by {
	my $increment = shift;
	$_->set_content ($_->literal + $increment) for @_;
}
