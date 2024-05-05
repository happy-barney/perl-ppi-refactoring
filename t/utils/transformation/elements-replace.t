
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_transformation q (should replace elements with their copy)
	=> document       => q (1; 2; 3;)
	=> where          => where { it_is_token_number q (2) }
	=> transformation => sub {
		elements_replace
			[
				current,                 # q (2)
				next_token,              # q (;)
				next_token (next_token), # q ( )
			],
			[
				next_token (next_token), # q ( )
				next_token,              # q (;)
				current,
				current,
				next_token,              # q (;)
				next_token (next_token), # q ( )
			],
	}
	=> expect         => q (1;  ;22; 3;)
	=> returns        => [
		expect_element (PPI::Token::Number::     => q (2)),
		expect_element (PPI::Token::Structure::  => q (;)),
		expect_element (PPI::Token::Whitespace:: => q ( )),
	];

had_no_warnings;
done_testing;
