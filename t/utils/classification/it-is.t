
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { &it_is };

my $token_number      = ppi_token q (0x1);
my $statement_package = ppi_statement q (package Foo);

subtest q (positive classification) => sub {
	assume_classification q (should classify using class classification)
		=> expect         => expect_ppi_include
		=> element        => $token_number
		=> conditions     => [ PPI::Token::Number:: ]
		;

	assume_classification q (should classify using content test)
		=> expect         => expect_ppi_include
		=> element        => $token_number
		=> conditions     => [ PPI::Token::Number::, q (0x1) ]
		;

	assume_classification q (should classify using multiple content tests)
		=> expect         => expect_ppi_include
		=> element        => $token_number
		=> conditions     => [ PPI::Token::Number::, [ q (0x1), qr ([12]) ] ]
		;

	assume_classification q (should classify using 'content' condition)
		=> expect         => expect_ppi_include
		=> element        => $statement_package->first_token
		=> conditions     => [
			PPI::Token::Word::,
			q (package),
			{ parent => { isa => PPI::Statement::Package:: } },
		];

	assume_classification q (should classify using 'accessor' condition)
		=> expect         => expect_ppi_include
		=> element        => $statement_package->first_token
		=> conditions     => [
			PPI::Token::Word::,
			{ parent => { isa => PPI::Statement::Package:: } },
		];

	assume_classification q (should classify using 'where' condition)
		=> expect         => expect_ppi_include
		=> element        => $statement_package
		=> conditions     => [
			PPI::Statement::Package::,
			where { it_is current->schild (1), PPI::Token::Word::, q (Foo) },
		];
};

subtest q (negative classification) => sub {
	assume_classification q (shouldn't classify using class classification)
		=> expect         => expect_ppi_exclude
		=> element        => $token_number
		=> conditions     => [ PPI::Token::Whitespace:: ]
		;

	assume_classification q (shouldn't classify using content compare)
		=> expect         => expect_ppi_exclude
		=> element        => $token_number
		=> conditions     => [ PPI::Token::Number::, q (0x2) ]
		;

	assume_classification q (should classify using multiple content comparisions)
		=> expect         => expect_ppi_exclude
		=> element        => $token_number
		=> conditions     => [ PPI::Token::Number::, q (0x1), qr ([12]), q (0x2) ]
		;

	assume_classification q (should classify using 'where' condition)
		=> expect         => expect_ppi_exclude
		=> element        => $statement_package
		=> conditions     => [
			PPI::Statement::Package::,
			where { it_is current->schild (1), PPI::Token::Word::, q (Bar) },
		];
};

had_no_warnings;
done_testing;


testing_classification { \& it_is };

my $element = PPI::Token::Word::->new (q (foo));

assert_classification q (should accept element when it is an instance of class)
	=> element => $element
	=> with    => [ PPI::Element:: ]
	=> expect  => expect_ppi_true
	;

assert_classification q (should reject element when it isn't an instance of class)
	=> element => $element
	=> with    => [ PPI::Statement:: ]
	=> expect  => expect_ppi_false
	;

assert_classification q (should accept element when it is an instance of class and matches content exactly)
	=> element => $element
	=> with    => [ PPI::Token::, q (foo) ]
	=> expect  => expect_ppi_true
	;

assert_classification q (should accept element when it is an instance of class and matches content by regex)
	=> element => $element
	=> with    => [ PPI::Token::, qr (o) ]
	=> expect  => expect_ppi_true
	;

assert_classification q (should reject element when it is an instance of class and doesn't match content exactly)
	=> element => $element
	=> with    => [ PPI::Token::, q (foo), q (bar) ]
	=> expect  => expect_ppi_false
	;

assert_classification q (should accept element when it is an instance of class and doesn't match content by regex)
	=> element => $element
	=> with    => [ PPI::Token::, q (foo), qr (b) ]
	=> expect  => expect_ppi_false
	;

assert_classification q (should reject element when it isn't an instance class even if content matches)
	=> element => $element
	=> with    => [ PPI::Statement::, q (foo) ]
	=> expect  => expect_ppi_false
	;

had_no_warnings;

done_testing;

