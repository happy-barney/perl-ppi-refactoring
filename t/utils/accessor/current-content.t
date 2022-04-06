
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

it "should return content of current element"
	=> got    => do { local $_ = PPI::Token::Word->new ('foo'); current_content }
	=> expect => 'foo'
	;

# Abusing anonymous Test::Deep::Cmp builder ...
my $dummy = test_deep_cmp (
	content => sub { 'foo-bar-baz' }
);

it "abusing test_deep_cmp() to create dummy class"
	=> got    => do { bless ({}, $dummy)->content }
	=> expect => 'foo-bar-baz'
	;

it "should return empty string when current element is not an instance of PPI::Element"
	=> got    => do { local $_ = bless {}, $dummy; current_content }
	=> expect => ''
	;

it "should return empty string when current element is not an instance"
	=> got    => do { local $_ = PPI::Element::; current_content }
	=> expect => ''
	;

it "should return empty string when current element is not defined"
	=> got    => do { local $_ = undef; current_content }
	=> expect => ''
	;

had_no_warnings;

done_testing;
