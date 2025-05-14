#!/usr/bin/env perl

use v5.14;
use warnings;

use Test::Tester;

use require::relative q (test-helper.pl);

# TODO: Test::YAFT - better diag messages

subtest q (success - instance of a class) => sub {
	Test::Tester::check_test
		sub {
			assume q (should pass)
				=> got    { PPI::Token::Number::->new (q (10)) }
				=> expect { expect_instance_of (PPI::Token::Number::) }
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

subtest q (failure - unblessed got) => sub {
	Test::Tester::check_test
		sub {
			assume q (should fail)
				=> got    { q (10) }
				=> expect { expect_instance_of (PPI::Token::Number::) }
				;
		},
		{
			ok          => 0,
			actual_ok   => 0,
			name        => q (should fail),
			diag        => <<'DIAG',
+----+-----+----+-------------------------------------+
| Elt|Got  | Elt|Expected                             |
+----+-----+----+-------------------------------------+
*   0|10   *   0|bless( {                             *
|    |     *   1|  val => 'PPI::Token::Number'        *
|    |     *   2|}, 'Test::Deep::Cmp::__ANON__::1' )  *
+----+-----+----+-------------------------------------+
Checking instance type of $data
   got : '10'
expect : blessed into 'PPI::Token::Number'
DIAG
		}
	;
};

subtest q (failure - unrelated class) => sub {
	Test::Tester::check_test
		sub {
			assume q (should fail)
				=> got    { PPI::Token::Word::->new (q (map)) }
				=> expect { expect_instance_of (PPI::Token::Number::) }
				;
		},
		{
			ok          => 0,
			actual_ok   => 0,
			name        => q (should fail),
			diag        => <<'DIAG',
+----+-------------------------+-------------------------------------+
| Elt|Got                      |Expected                             |
+----+-------------------------+-------------------------------------+
|   0|bless( {                 |bless( {                             |
*   1|  content => 'map'       |  val => 'PPI::Token::Number'        *
*   2|}, 'PPI::Token::Word' )  |}, 'Test::Deep::Cmp::__ANON__::1' )  *
+----+-------------------------+-------------------------------------+
Checking instance type of $data
   got : blessed into 'PPI::Token::Word'
expect : blessed into 'PPI::Token::Number'
DIAG
		}
	;
};

subtest q (failure - child class) => sub {
	Test::Tester::check_test
		sub {
			assume q (should fail)
				=> got    { PPI::Token::Number::Octal::->new (q (010)) }
				=> expect { expect_instance_of (PPI::Token::Number::) }
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

