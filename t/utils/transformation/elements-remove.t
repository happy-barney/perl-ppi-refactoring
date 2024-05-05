
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_transformation { &elements_remove };

assume_transformation q (should remove single element)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (1) }
	=> expect         => q (; 2; 3;)
	=> returns        => [
		expect_element (PPI::Token::Number:: => q (1)),
	];

assume_transformation q (should remove multiple elements)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number }
	=> arguments      => sub { [ @_ ] }
	=> expect         => q (; ; ;)
	=> returns        => [
		expect_element (PPI::Token::Number:: => q (1)),
		expect_element (PPI::Token::Number:: => q (2)),
		expect_element (PPI::Token::Number:: => q (3)),
	];

assume_transformation q (shouldn't fail when multiple elements is empty list)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number }
	=> arguments      => sub { [ ] }
	=> expect         => q (1; 2; 3;)
	=> returns        => [
	];

assume_transformation q (shouldn't fail when multiple elements contains no-elements)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number }
	=> arguments      => sub { [ $_[0], no_element, undef, $_[2] ] }
	=> expect         => q (; 2; ;)
	=> returns        => [
		expect_element (PPI::Token::Number:: => q (1)),
		expect_element (PPI::Token::Number:: => q (3)),
	];

had_no_warnings;
done_testing;
