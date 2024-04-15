
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

sub document {
	state $document;
	$document = ppi_document q (1;foo;2;bar)
};

assume q (ppix_search() without arguments should return empty list)
	=> got    { [ ppix_search ] }
	=> expect => [ ]
	;

assume q (ppix_search() without where clause should return empty list)
	=> got    { [ ppix_search document () ] }
	=> expect => [ ]
	;

assume q (ppix_search() should populate current element for PPIx::Augment where clause)
	=> got    { [ ppix_search document () => where { $_->isa (PPI::Token::Number::) } ] }
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

assume q (ppix_search() should populate current element for plain sub where clause)
	=> got    { [ ppix_search document () => sub { $_->isa (PPI::Token::Number::) } ] }
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

assume q (ppix_search() should provide PPI compatible arguments for PPIx::Augment where clause)
	=> got    { [ ppix_search document () => where { $_[1]->isa (PPI::Token::Number::) } ] }
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

assume q (ppix_search() should provide PPI compatible arguments for plain sub where clause)
	=> got    { [ ppix_search document () => sub { $_[1]->isa (PPI::Token::Number::) } ] }
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

assume q (ppix_search() should evaluate PPI comparator)
	=> got    { [ ppix_search document () => sub { $_[1]->isa (PPI::Token::Number::) } ] }
	=> expect => [
		expect_element (PPI::Token::Number::, 1),
		expect_element (PPI::Token::Number::, 2),
	];

assume q (ppix_search() should evaluate all conditions)
	=> got    { [
		ppix_search document ()
			=> where { $_->isa (PPI::Token::Number::) }
			=> sub { $_[1]->content eq q (2) }
	] }
	=> expect => [
		expect_element (PPI::Token::Number::, 2),
	];

assume q (ppix_search() should invoke provided code() on found elements)
	=> got    { [
		ppix_search document ()
			=> where { $_->isa (PPI::Token::Number::) }
			=> invoke { $_->set_content ($_->content . q (_001)) }
			=> invoke { $_->set_content ($_->content . q (_002)) }
	] }
	=> expect => [
		expect_element (PPI::Token::Number:: => q (1_001_002)),
		expect_element (PPI::Token::Number:: => q (2_001_002)),
	];

assume q (ppix_search() in scalar context without start element should return no_element ())
	=> got    { scalar ppix_search }
	=> expect => expect_no_element
	;

assume q (ppix_search() in scalar context without where clause should return no_element ())
	=> got    { scalar ppix_search document () }
	=> expect => expect_no_element
	;

assume q (ppix_search() in scalar context should return no_element () instead of empty list)
	=> got    { scalar ppix_search document () => where { $_[1]->isa (PPI::Token::Magic::) } }
	=> expect => expect_no_element
	;

assume q (ppix_search() in scalar context should return only first found element)
	=> got    { scalar ppix_search document () => where { $_[1]->isa (PPI::Token::Number::) } }
	=> expect => expect_element (PPI::Token::Number::, 1)
	;

had_no_warnings;
done_testing;

