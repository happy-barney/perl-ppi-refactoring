
use v5.14;
use warnings;

use require::relative q (test-helper.pl);

act { PPIx::Augment::Utils::_classification_conditions (map @$_, @_) }
	q (element),
	q (conditions),
	;

my $document = ppi_document (q (my $foo = 1;));
arrange { element => [ $document->first_token ] };

assume q ('no-condition' - it should pass when there is no condition)
	=> expect          => & expect_ppi_include
	=> with_conditions => [ ]
	;

assume q ('string-compare' - it should pass when there is matching condition)
	=> expect          => & expect_ppi_include
	=> with_conditions => [ q (my) ]
	;

assume q ('string-compare' - it should fail when there isn't matching condition)
	=> expect          => & expect_ppi_exclude
	=> with_conditions => [ q (my), q (our) ]
	;

assume q ('boolean-compare' - it should pass when there is a 'undef' condition on 'element')
	=> expect          => & expect_ppi_include
	=> with_conditions => [ undef ]
	;

assume q ('boolean-compare' - it should fail when there is a 'undef' condition on 'no_element')
	=> expect          => & expect_ppi_exclude
	=> with_element    => [ no_element ]
	=> with_conditions => [ undef ]
	;

assume q ('string-match' - it should pass when there is matching condition)
	=> expect          => & expect_ppi_include
	=> with_conditions => [ qr (\w+) ]
	;

assume q ('string-match' - it should fail when there isn't matching condition)
	=> expect          => & expect_ppi_exclude
	=> with_conditions => [ qr (\w+), qr (\d+) ]
	;

assume q ('where' - it should pass when there is matching condition)
	=> expect          => & expect_ppi_include
	=> with_conditions => [
		sub { $_->isa (PPI::Token::Word::) },
	];

assume q ('where' - it should fail when there isn't matching condition)
	=> expect          => & expect_ppi_exclude
	=> with_conditions => [
		sub { $_->isa (PPI::Token::Word::) },
		sub { $_->isa (PPI::Token::Number::) },
	];

assume q ('where' - it should fail early and not evaluate subsequent conditions)
	=> expect          => & expect_ppi_exclude
	=> with_conditions => [
		sub { $_->isa (PPI::Token::Number::) },
		sub { die q (Should not evaluate condition once previous failed) },
	];

assume q ('where' - it should not consume exceptions)
	=> throws          => { error => q (expected-exception) }
	=> with_conditions => [
		sub { die { error => q (expected-exception) } },
	];

assume q ('accessor' - it should pass with matching nested conditions)
	=> expect          => & expect_ppi_include
	=> with_conditions => [
		{ parent => { isa => PPI::Statement::Variable:: } },
		{ snext_sibling => { significant => undef } },
		{ next_sibling => { next_sibling => { significant => undef } } },
	];

assume q ('accessor' - it should fail with non-matching nested conditions)
	=> expect          => & expect_ppi_exclude
	=> with_conditions => [
		{ parent => { isa => PPI::Statement::Variable:: } },
		{ next_sibling => { significant => undef } },
	];

had_no_warnings;
done_testing;
