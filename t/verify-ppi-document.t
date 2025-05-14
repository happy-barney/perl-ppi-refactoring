
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

act { ppi_document (@_) }
	q (source)
	;

assume q (ppi_document () should parse inline source)
	=> with_source => q (string),
	=> expect      =>
		expect_obj_isa (PPI::Document::)
		& expect_method (content => q (string))
	;

assume q (ppi_document () should parse Path::Tiny referenced source)
	=> with_source => tests_root->child (qw (fixture simple-document.pl))
	=> expect      =>
		expect_obj_isa (PPI::Document::)
		& expect_method (content => qq (1;\n))
	;

use FindBin;

assume q (ppi_document () should parse scalar referenced source)
	=> with_source => $FindBin::Dir . q (/fixture/simple-document.pl)
	=> expect      =>
		expect_obj_isa (PPI::Document::)
		& expect_method (content => qq (1;\n))
	;

my $document = PPI::Document::->new (\ q (2;));
assume q (ppi_document () should pass-through instance of PPI::Document)
	=> with_source => $document
	=> expect      =>
		expect_obj_isa (PPI::Document::)
		& expect_method (content => q (2;))
	;

my $element = PPI::Token::Word::->new (q (map));
assume q (ppi_document () should pass-through instance of PPI::Element)
	=> with_source => $element
	=> expect      =>
		expect_obj_isa (PPI::Element::)
		& expect_method (content => q (map))
	;

had_no_warnings;
done_testing;

__END__

