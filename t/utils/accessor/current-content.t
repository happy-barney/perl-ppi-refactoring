
use v5.14;
use warnings;

use require::relative q (../../test-helper.pl);

it q (should return content of current element)
	=> got    => do { local $_ = PPI::Token::Word->new (q (foo)); current_content }
	=> expect => q (foo)
	;

# Abusing anonymous Test::Deep::Cmp builder ...
my $dummy = test_deep_cmp (
	content => sub { q (foo-bar-baz) }
);

it q (abusing test_deep_cmp() to create dummy class)
	=> got    => do { bless ({}, $dummy)->content }
	=> expect => q (foo-bar-baz)
	;

it q (should return empty string when current element is not an instance of PPI::Element)
	=> got    => do { local $_ = bless {}, $dummy; current_content }
	=> expect => q ()
	;

it q (should return empty string when current element is not an instance)
	=> got    => do { local $_ = PPI::Element::; current_content }
	=> expect => q ()
	;

it q (should return empty string when current element is not defined)
	=> got    => do { local $_ = undef; current_content }
	=> expect => q ()
	;

had_no_warnings;

done_testing;
