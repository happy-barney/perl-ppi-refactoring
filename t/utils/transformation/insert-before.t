
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

my $four = build_token_number_decimal (4);
my $five = build_token_number_decimal (5);

testing_transformation { insert_before @_ };

assume_transformation q (should insert elements before current element)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> arguments      => sub { [ $four, $five ] }
	=> expect         => q (1; 452; 3;)
	;

assume_transformation q (should insert elements before effective element)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> arguments      => sub { next_token, [ $four, $five ] }
	=> expect         => q (1; 245; 3;)
	;

assume_transformation q (should clone inserted elements before inserting)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> transformation => insert_token_from_another_statement
	=> expect         => q (1; 4352; 333;)
	;

assume_transformation q (shouldn't fail when there is empty list to insert)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> arguments      => sub { [ ] }
	=> expect         => q (1; 2; 3;)
	;

had_no_warnings;
done_testing;

sub insert_token_from_another_statement {
	my $three = current->parent->snext_sibling->first_token;
	insert_before [ $four, $three, $five ];
	$three->set_content (q (333));
}

