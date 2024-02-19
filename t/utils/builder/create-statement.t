
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should build empty statement"
	=> got    => create_statement ()
	=> expect => expect_element ('PPI::Statement', [])
	;

it "should ignore arguments which are not PPI::Element:: instances"
	=> got    => create_statement (undef, '', PPI::Element::, bless {}, 'Bar')
	=> expect => expect_element ('PPI::Statement', [])
	;

it "should build statement with provided content"
	=> got    => create_statement (
		create_token_word ('foo'),
		create_token_semicolon,
	)
	=> expect => expect_element ('PPI::Statement' => (
		expect_element ('PPI::Token::Word'      => 'foo'),
		expect_element ('PPI::Token::Structure' => ';'),
	));

my $foo = create_token_word ('foo');
my $parent = create_statement ($foo, create_token_semicolon);

it "should build statement with elements with parent"
	=> got    => my $statement = create_statement (
		$foo,
		create_token_semicolon,
	)
	=> expect => expect_element ('PPI::Statement' => (
		expect_element ('PPI::Token::Word'      => 'foo'),
		expect_element ('PPI::Token::Structure' => ';'),
	));

ok "should clone elements with parent"
	=> got    => $foo != $statement->child (0)
	;

it "should not remove cloned element from its parent"
	=> got    => $parent
	=> expect => expect_element ('PPI::Statement' => (
		expect_element ('PPI::Token::Word'      => 'foo'),
		expect_element ('PPI::Token::Structure' => ';'),
	));

had_no_warnings;

done_testing;
