
use v5.14;
use warnings;

use Test::Tester;

use require::relative q (test-helper.pl);

subtest q (expect_entity () should check instance class) => sub {
	Test::Tester::check_test
		sub {
			assume q (should pass)
				=> got    { PPI::Token::Number::->new (q (10)) }
				=> expect { expect_ppi_token_number }
				;
		},
		{
			ok          => 1,
			actual_ok   => 1,
			name        => q (should pass),
			diag        => q (),
		}
	;
};

subtest q (expect_entity () should check instance class and its content) => sub {
	Test::Tester::check_test
		sub {
			assume q (should pass)
				=> got    { PPI::Token::Number::->new (q (10)) }
				=> expect { expect_ppi_token_number q (10) }
				;
		},
		{
			ok          => 1,
			actual_ok   => 1,
			name        => q (should pass),
			diag        => q (),
		}
	;
};

subtest q (expect_entity () should fail on content comparison) => sub {
	Test::Tester::check_test
		sub {
			assume q (should fail)
				=> got    { PPI::Token::Number::->new (q (10)) }
				=> expect { expect_ppi_token_number q (11) }
				;
		},
		{
			ok          => 0,
			actual_ok   => 0,
			name        => q (should fail),
			diag        => <<'DIAG',
+----+---------------------------+----+------------------------------------------+
| Elt|Got                        | Elt|Expected                                  |
+----+---------------------------+----+------------------------------------------+
|   0|bless( {                   |   0|bless( {                                  |
*   1|  content => 10            *   1|  val => [                                *
*   2|}, 'PPI::Token::Number' )  *   2|    bless( {                              *
|    |                           *   3|      val => 'PPI::Token::Number'         *
|    |                           *   4|    }, 'Test::Deep::Cmp::__ANON__::1' ),  *
|    |                           *   5|    bless( {                              *
|    |                           *   6|      methods => [                        *
|    |                           *   7|        [                                 *
|    |                           *   8|          [                               *
|    |                           *   9|            'content'                     *
|    |                           *  10|          ],                              *
|    |                           *  11|          11                              *
|    |                           *  12|        ]                                 *
|    |                           *  13|      ]                                   *
|    |                           *  14|    }, 'Test::Deep::Methods' )            *
|    |                           *  15|  ]                                       *
|    |                           *  16|}, 'Test::Deep::All' )                    *
+----+---------------------------+----+------------------------------------------+
Compared (Part 2 of 2 in $data)->content
   got : '10'
expect : '11'
DIAG
		}
	;
};

subtest q (expect_entity () should fail on method comparison) => sub {
	Test::Tester::check_test
		sub {
			assume q (should fail)
				=> got    { PPI::Token::Number::Octal::->new (q (010)) }
				=> expect { expect_ppi_token_number }
				;
		},
		{
			ok          => 0,
			actual_ok   => 0,
			name        => q (should fail),
			diag        => <<'DIAG',
+----+----------------------------------+-------------------------------------+
| Elt|Got                               |Expected                             |
+----+----------------------------------+-------------------------------------+
|   0|bless( {                          |bless( {                             |
*   1|  content => '010'                |  val => 'PPI::Token::Number'        *
*   2|}, 'PPI::Token::Number::Octal' )  |}, 'Test::Deep::Cmp::__ANON__::1' )  *
+----+----------------------------------+-------------------------------------+
Checking instance type of $data
   got : blessed into 'PPI::Token::Number::Octal'
expect : blessed into 'PPI::Token::Number'
DIAG
		}
	;
};

had_no_warnings;
done_testing;
