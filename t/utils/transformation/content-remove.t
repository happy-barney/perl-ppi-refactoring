
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume_transformation q (should alter content of current element)
	=> document       => <<'END_OF_DOCUMENT'
134;
3567;
END_OF_DOCUMENT
	=> where          => where { it_is_token_number qr (\d\d\d$) }
	=> transformation => sub {
		for (@_) {
			insert_before [
				build_token_number (content_remove qr (\d+(?=\d\d$))x),
				build_token_whitespace (q ( )),
				build_token_operator   (q (+)),
				build_token_whitespace (q ( )),
			];
		}
	}
	=> expect         => <<'END_OF_DOCUMENT'
1 + 34;
35 + 67;
END_OF_DOCUMENT
	;

had_no_warnings;
done_testing;

