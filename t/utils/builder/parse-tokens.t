
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume q (it should parse every provided snippet)
	=> got    { [ parse_tokens (q ( ), q (=), q (01)) ] }
	=> expect => [
		expect_element (PPI::Token::Whitespace::    => q ( )),
		expect_element (PPI::Token::Operator::      => q (=)),
		expect_element (PPI::Token::Number::Octal:: => q (01)),
	];

assume q (it shouldn't concat provided snippets)
	=> got    { [ parse_tokens (q (=), q (=) ) ] }
	=> expect => [
		expect_element (PPI::Token::Operator::      => q (=)),
		expect_element (PPI::Token::Operator::      => q (=)),
	];

assume q (it should return all parsed tokens)
	=> got    { [ parse_tokens (q (01 ==)) ] }
	=> expect => [
		expect_element (PPI::Token::Number::Octal:: => q (01)),
		expect_element (PPI::Token::Whitespace::    => q ( )),
		expect_element (PPI::Token::Operator::      => q (==)),
	];

assume q (it should ignore empty snippets)
	=> got    { [ parse_tokens (q (), q (=), undef) ] }
	=> expect => [
		expect_element (PPI::Token::Operator::      => q (=)),
	];

assume q (when no valid content is provided it should return empty list)
	=> got    { [ parse_tokens (q (), undef ) ] }
	=> expect => [
	];

assume q (it should ignore undef parameter(s))
	=> got    { [ parse_tokens ( q (=), undef, undef) ] }
	=> expect => [
		expect_element (PPI::Token::Operator::      => q (=)),
	];

had_no_warnings;
done_testing;
