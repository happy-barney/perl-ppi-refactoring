
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

package Test::Augmentation::Single { };
package Test::Augmentation::Multi::Array { };
package Test::Augmentation::Multi::Code { };

assume_augmentation q (implicit behaviour using predefined methods with single case)
	=> document       => q (0x1;0x2;0x3;)
	=> augmentation   => Test::Augmentation::Single::
	=> expect_analyze => [
		expect_element (PPI::Token::Number::Hex::, q (0x1)),
		expect_element (PPI::Token::Number::Hex::, q (0x2)),
	]
	=> expect_augment => 3
	=> expect_result  => q (3;2;0x1;3;0x2;0x3;)
	;

assume_augmentation q (implicit behaviour using predefined methods with multiple cases)
	=> document       => q (1;0x1;0x2;0x3;3)
	=> augmentation   => Test::Augmentation::Multi::Code::
	=> expect_analyze => expect_bag (
		expect_element (PPI::Token::Number::,      q (1)),
		expect_element (PPI::Token::Number::Hex::, q (0x1)),
		expect_element (PPI::Token::Number::Hex::, q (0x3)),
		expect_element (PPI::Token::Number::,      q (3)),
	)
	=> expect_augment => 4
	=> expect_result  => q (42;0x42;0x2;0x24;24)
	;

assume_augmentation q (implicit behaviour using predefined methods with multiple cases)
	=> document       => q (1;0x1;0x2;0x3;3)
	=> augmentation   => Test::Augmentation::Multi::Array::
	=> expect_analyze => expect_bag (
		expect_element (PPI::Token::Number::,      q (1)),
		expect_element (PPI::Token::Number::Hex::, q (0x1)),
		expect_element (PPI::Token::Number::Hex::, q (0x3)),
		expect_element (PPI::Token::Number::,      q (3)),
	)
	=> expect_augment => 4
	=> expect_result  => q (42;0x42;0x2;0x24;24)
	;

had_no_warnings;
done_testing;

package Test::Augmentation::Single {
	use parent qw (PPIx::Augment::Augmentation);

	sub how_to_augment {
		::invoke {
			::current->insert_before (PPI::Token::Number::->new (::current->literal + 1));
			::current->insert_before (PPI::Token::Structure::->new (q (;)));
		}
	}

	sub what_to_augment {
		::where { ::it_is_token_number },
		::where { ::current->literal < 3 },
	}
}

package Test::Augmentation::Multi::Array {
	use parent qw (PPIx::Augment::Augmentation);

	sub how_to_augment {
		+{
			alter_one   => [ ::invoke { ::current->set_content (::content =~ s (1) (42)r) } ],
			alter_three => [ ::invoke { ::current->set_content (::content =~ s (3) (24)r) } ],
		}
	}

	sub what_to_augment {
		+{
			alter_one   => [ ::where { ::it_is_token_number { literal => 1 } } ],
			alter_three => [ ::where { ::it_is_token_number { literal => 3 } } ],
		}
	}
}

package Test::Augmentation::Multi::Code {
	use parent qw (PPIx::Augment::Augmentation);

	sub how_to_augment {
		+{
			alter_one   => ::invoke { ::current->set_content (::content =~ s (1) (42)r) },
			alter_three => ::invoke { ::current->set_content (::content =~ s (3) (24)r) },
		}
	}

	sub what_to_augment {
		+{
			alter_one   => ::where { ::it_is_token_number { literal => 1 } },
			alter_three => ::where { ::it_is_token_number { literal => 3 } },
		}
	}
}

