
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

arrange_document { <<'END_OF_DOCUMENT' };
my $foo;
our $bar;
state $baz;
END_OF_DOCUMENT

assume_ppi q (should classify using 'its_first_child')
	=> classification => sub { its_first_child { it_is_token_word q (our) } }
	=> expect         => expect_nodeset (
		expect_element (PPI::Statement::Variable:: => q (our $bar;)),
	);

had_no_warnings;
done_testing;

