
use v5.14;
use warnings;

use Carp::Always; # must be before Test::YAFT - replaces $SIG{__WARN__}

use Context::Singleton;
use PPI v1.278;
use PPI::Dumper;
use Path::Tiny;
use Safe::Isa;
use Test::YAFT qw (:all);

{
	### TODO: functions which should be available in respective modules
	### TODO: move them there

	no warnings q (once);

	*assume = \ &it
		unless __PACKAGE__->can (q (assume))
		;

	*deduce_undef = sub { return try_deduce (@_) ? undef : deduce (@_) }
		unless __PACKAGE__->can (q (deduce_undef))
		;

	*expect = sub (&) { expect => shift->() }
		unless __PACKAGE__->can (q (expect))
		;

	*expect_defined = sub { ! expect_value (undef) }
		unless __PACKAGE__->can (q (expect_defined))
		;

	*expect_method = \ &expect_methods
		unless __PACKAGE__->can (q (expect_method))
		;
}

sub distribution_root;
sub expect_instance_of;
sub ppi_document;
sub ppi_dump;
sub tests_root;

sub distribution_root {
	return tests_root->parent;
}

sub expect_element {
	my ($class, @children) = @_;

	my $expectation = expect_instance_of ($class);

	$expectation &= expect_methods (content => shift @children)
		if @children && ! ref $children[0]
		;

	$expectation &= expect_methods (%{ shift @children })
		if @children && Ref::Util::is_plain_hashref ($children[0])
		;

	$expectation &= expect_listmethods (children => shift @children)
		if @children == 1 && Ref::Util::is_plain_arrayref ($children[0])
		;

	$expectation &= expect_listmethods (children => \ @children)
		if @children
		;

	return $expectation;
}

sub expect_instance_of {
	state $class = test_deep_cmp (
		isa             => [ Test::Deep::Obj:: ],
		descend         => sub {
			my ($self, $got) = @_;
			return $self->Test::Deep::Obj::descend ($got) && ref ($got) eq $self->{val};
		},
		diag_message    => sub {
			my ($self, $where) = @_;
			return qq (Checking instance type of $where);
		},
		renderGot       => sub {
			my ($self, $got) = @_;

			return $self->Test::Deep::Obj::renderGot ($got)
				unless Scalar::Util::blessed ($got);
			return qq (blessed into '${\ ref $got }');
		},
		renderExp       => sub {
			my ($self) = @_;
			return qq (blessed into '$self->{val}');
		},
	);

	return @_
		? $class->new (@_)
		: $class
		;
}

sub expect_nodeset {
	return [ @_ ];
}

sub expect_ppi_structure_block {
	return expect_element (PPI::Structure::Block::, @_);
}

sub expect_ppi_token_heredoc {
	return expect_element (PPI::Token::HereDoc::, @_);
}

sub expect_ppi_token_number {
	return expect_element (PPI::Token::Number::, @_);
}

sub expect_ppi_token_operator {
	return expect_element (PPI::Token::Operator::, @_);
}

sub expect_ppi_token_prototype {
	return expect_element (PPI::Token::Prototype::, @_);
}

sub expect_ppi_token_structure {
	return expect_element (PPI::Token::Structure::, @_);
}

sub expect_ppi_token_symbol {
	return expect_element (PPI::Token::Symbol::, @_);
}

sub expect_ppi_token_whitespace {
	return expect_element (PPI::Token::Whitespace::, @_);
}

sub expect_ppi_token_word {
	return expect_element (PPI::Token::Word::, @_);
}

sub ppi_document {
	my ($source) = @_;

	return
		unless defined $source
		;

	return $source
		if $source->$Safe::Isa::_isa (PPI::Element::)
		;

	$source = qq ($source)
		if ref $source
		;

	PPI::Document::->new (
		($source =~ m/\n/ || ! -e $source)
			? \ $source
			: $source
		);
}

sub ppi_dump {
	diag (PPI::Dumper::->new ($_)->string =~ s ((?<= [#])) (    )xr)
		for
		map { ppi_document ($_) }
		map { Ref::Util::is_plain_arrayref ($_) ? @$_ : $_ }
		@_
		;
}

sub tests_root {
	return Path::Tiny::->new (__FILE__)->parent;
}

1;

