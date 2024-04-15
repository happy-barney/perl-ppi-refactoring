
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

assume q (ppi_transform() should not process any where/invoke when element is not a PPI::Element)
	=> expect => -1
	=> got    => ppix_transform (
		PPI::Element::
		=> where { fail q (where should not be called) }
		=> invoke { fail q (invoke should not be called) }
	);

assume q (ppi_transform() should not run any invoke when where is missing)
	=> expect => -1
	=> got    => ppix_transform (
		ppi_document (q ())
		=> invoke { fail q (invoke should not be called) }
	);

assume q (ppi_transform() should not run any where when invoke is missing)
	=> expect => -1
	=> got    => ppix_transform (
		ppi_document (q ())
		=> where { fail q (where should not be called) }
	);

my $document = ppi_document q (0x1;0x2;0x3;);
assume q (ppi_transform() should process newly created elements as well)
	=> expect =>
		+ 2 # from insertions before 0x1
		+ 1 # from insertions before 0x2
	=> got    => ppix_transform (
		$document
		=> where { current->isa (PPI::Token::Number::) }
		=> where { current->literal < 3 }
		=> invoke {
			current->insert_before (PPI::Token::Number::->new (current->literal + 1));
			current->insert_before (PPI::Token::Structure::->new (q (;)));
		}
	);

assume q (ppi_transform() should modify document)
	=> got    => $document->serialize
	=> expect => q (3;2;0x1;3;0x2;0x3;)
	;

had_no_warnings;
done_testing;

