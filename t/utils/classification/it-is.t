
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { \ &it_is };

my $element = PPI::Token::Number::Hex::->new (q (0x1));
my $package = PPI::Statement::Package::->new ();
$package->add_element (my $nested = PPI::Token::Word::->new (q (package)));

subtest q (positive classification) => sub {
	assume_classification q (should classify using class classification)
		=> expect         => expect_ppi_include
		=> element        => $element
		=> conditions     => [ PPI::Token::Number:: ]
		;

	not 1 and assume_classification q (should classify using content test)
		=> expect         => expect_ppi_include
		=> element        => $element
		=> conditions     => [ PPI::Token::Number::, q (0x1) ]
		;

	not 1 and assume_classification q (should classify using multiple content tests)
		=> expect         => expect_ppi_include
		=> element        => $element
		=> conditions     => [ PPI::Token::Number::, [ q (0x1), qr ([12]) ] ]
		;

	not 1 and assume_classification q (should classify using nested non-content tests)
		=> expect         => expect_ppi_include
		=> element        => $nested
		=> conditions     => [
			PPI::Token::Word::,
			q (package),
			{ parent => { isa => PPI::Statement::Package:: } },
		];
};

not 1 and subtest q (negative classification) => sub {
	assume_classification q (shouldn't classify using class classification)
		=> expect         => expect_ppi_exclude
		=> element        => $element
		=> conditions     => [ PPI::Token::Whitespace:: ]
		;

	assume_classification q (shouldn't classify using content compare)
		=> expect         => expect_ppi_exclude
		=> element        => $element
		=> conditions     => [ PPI::Token::Number::, q (0x2) ]
		;

	assume_classification q (should classify using multiple content comparisions)
		=> expect         => expect_ppi_exclude
		=> element        => $element
		=> conditions     => [ PPI::Token::Number::, [ q (0x1), qr ([12]), q (0x2) ] ]
		;

	assume_classification q (should classify using nested non-content tests)
		=> expect         => expect_ppi_exclude
		=> element        => $nested
		=> conditions     => [
			PPI::Token::Word::,
			q (package),
			{ parent => { isa => PPI::Statement::Sub:: } },
		];
};

had_no_warnings;
done_testing;
