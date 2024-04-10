
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

testing_classification { it_is_token_separator @_ };

assume_ppi q (should match any instance of PPI::Token::Separator::)
	=> document   => <<'END_OF_DOCUMENT'
__END__
__DATA__
END_OF_DOCUMENT
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Separator:: => q (__END__)),
	);

assume_ppi q (should accept additional conditions)
	=> document   => <<'END_OF_DOCUMENT'
__DATA__
__END__
END_OF_DOCUMENT
	=> expect     => expect_nodeset (
		expect_element (PPI::Token::Separator:: => q (__DATA__)),
	);
had_no_warnings;
done_testing;

