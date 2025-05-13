
use v5.14;
use warnings;

use Test::Tester;

use require::relative q (test-helper.pl);

subtest q (expect_entity () should check instance class) => sub {
	Test::Tester::check_test
		sub {
			assume q (should pass)
				=> got    { PPI::Token::Number::->new (q (10)) }
				=> expect { expect_element (PPI::Token::Number::) }
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
				=> expect { expect_element (PPI::Token::Number:: => q (10)) }
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
				=> expect { expect_element (PPI::Token::Number:: => q (11)) }
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
				=> expect { expect_element (PPI::Token::Number::Octal:: => { literal => 7 }) }
				;
		},
		{
			ok          => 0,
			actual_ok   => 0,
			name        => q (should fail),
			diag        => <<'DIAG',
+----+----------------------------------+----+------------------------------------------+
| Elt|Got                               | Elt|Expected                                  |
+----+----------------------------------+----+------------------------------------------+
|   0|bless( {                          |   0|bless( {                                  |
*   1|  content => '010'                *   1|  val => [                                *
*   2|}, 'PPI::Token::Number::Octal' )  *   2|    bless( {                              *
|    |                                  *   3|      val => 'PPI::Token::Number::Octal'  *
|    |                                  *   4|    }, 'Test::Deep::Cmp::__ANON__::1' ),  *
|    |                                  *   5|    bless( {                              *
|    |                                  *   6|      methods => [                        *
|    |                                  *   7|        [                                 *
|    |                                  *   8|          [                               *
|    |                                  *   9|            'literal'                     *
|    |                                  *  10|          ],                              *
|    |                                  *  11|          7                               *
|    |                                  *  12|        ]                                 *
|    |                                  *  13|      ]                                   *
|    |                                  *  14|    }, 'Test::Deep::Methods' )            *
|    |                                  *  15|  ]                                       *
|    |                                  *  16|}, 'Test::Deep::All' )                    *
+----+----------------------------------+----+------------------------------------------+
Compared (Part 2 of 2 in $data)->literal
   got : '8'
expect : '7'
DIAG
		}
	;
};

had_no_warnings;
done_testing;
