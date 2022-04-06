
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should replace element with empty elements"
	=> got    => do {
		my $document = document ("1;2;{3}");
		ppix_transform $document
			=> where { it_is_token_number "1" }
			=> invoke {
				current_replace '', '', '';
			};
		$document->serialize;
	}
	=> expect => ";2;{3}"
	;

it "should replace element with given elements"
	=> got    => do {
		my $document = document ("1;2;{3}");
		ppix_transform $document
			=> where { it_is_token_number "1" }
			=> invoke {
				current_replace (
					PPI::Token::Number->new ("11"),
					PPI::Token::Structure->new (";"),
					PPI::Token::Number->new ("22"),
				);
			};
		$document->serialize;
	}
	=> expect => "11;22;2;{3}"
	;

it "should move element from it's current parent"
	=> got    => do {
		my $document = document ("1;2;{3}");
		ppix_transform $document
			=> where { it_is_token_number "1" }
			=> invoke {
				current_replace (
					@{ $document->find (sub { ($_[1]->content eq '3') }) }
				);
			};
		$document->serialize;
	}
	=> expect => "3;2;{}"
	;

it "should replace multiple elements"
	=> got    => do {
		my $document = document ("1;2;{3}");
		ppix_transform $document
			=> where { it_is_token_number "1" }
			=> invoke {
				element_replace (
					[ current, next_sibling ],
					create_token_word ('foo'),
					create_token_whitespace (' '),
				);
			};
		$document->serialize;
	}
	=> expect => "foo 2;{3}"
	;

had_no_warnings;

done_testing;
