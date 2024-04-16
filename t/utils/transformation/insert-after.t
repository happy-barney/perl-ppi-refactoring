
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

my $four = build_token_number_decimal (4);
my $five = build_token_number_decimal (5);

testing_transformation { &insert_after };

assume_transformation q (should insert elements after current element)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> arguments      => sub { [ $four, $five ] }
	=> expect         => q (1; 245; 3;)
	=> returns        => [
		expect_element (PPI::Token::Number::, q (4)),
		expect_element (PPI::Token::Number::, q (5)),
	];

assume_transformation q (should insert elements after effective element)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> arguments      => sub { next_token, [ $four, $five ] }
	=> expect         => q (1; 2;45 3;)
	;

assume_transformation q (should clone inserted elements after inserting)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> transformation => insert_token_from_another_statement
	=> expect         => q (1; 2435; 333;)
	;

assume_transformation q (shouldn't fail when there is empty list to insert)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> arguments      => sub { [ ] }
	=> expect         => q (1; 2; 3;)
	=> returns        => [ ]
	;

assume_transformation q (in scalar context should return should return first inserted element)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> transformation => sub { scalar &insert_after }
	=> arguments      => sub { [ $four, $five ] }
	=> expect         => q (1; 245; 3;)
	=> returns        => [
		expect_element (PPI::Token::Number::, q (4)),
	];

assume_transformation q (in scalar context should return 'undef' when no element was inserted)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> transformation => sub { scalar &insert_after }
	=> arguments      => sub { [ no_element ] }
	=> expect         => q (1; 2; 3;)
	=> returns        => [
		undef
	];

had_no_warnings;
done_testing;

sub insert_token_from_another_statement {
	my $three = current->parent->snext_sibling->first_token;
	insert_after [ $four, $three, $five ];
	$three->set_content (q (333));
}

