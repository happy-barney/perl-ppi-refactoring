
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

my $document = ppi_document q (1;foo;2;bar);

it q (ppix_find() without arguments should return empty list)
	=> got    => [ ppix_find ]
	=> expect => [ ]
	;

it q (ppix_find() without where clause should return empty list)
	=> got    => [ ppix_find $document ]
	=> expect => [ ]
	;

it q (ppix_find() should evaluate PPIx::Augment where clause)
	=> arrange { document => ppi_document (q (1;foo;2;bar)) }
	=> got     {
		[
			ppix_find deduce (q (document))
				=> where { $_->isa (PPI::Token::Number::) }
		]
	}
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

it q (ppix_find() should evaluate PPI comparator)
	=> got    => [
		ppix_find $document
			=> sub { $_[1]->isa (PPI::Token::Number::) }
	]
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

it q (ppix_find() should evaluate all conditions)
	=> got    => [
		ppix_find $document
			=> where { $_->isa (PPI::Token::Number::) }
			=> sub { $_[1]->content eq q (2) }
	]
	=> expect => [
		expect_element (PPI::Token::Number::, 2),
	];

had_no_warnings;
done_testing;

