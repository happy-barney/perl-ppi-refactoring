
use v5.14;
use warnings;

use require::relative "test-helper.pl";

use Ref::Util;
use Pod::Simple::SimpleTree;

require PPI;
require PPIx::Augment::Elements;

note <<'';
	Every PPI class should have it's PPIx::Augment counterpar

plan tests => 3;

subtest "PPI nodes counterparts" => sub {
	sub behaves_like_augmented_ppi_class;

	plan tests => 69;

	behaves_like_augmented_ppi_class 'PPI::Node';
	behaves_like_augmented_ppi_class 'PPI::Document';
	behaves_like_augmented_ppi_class 'PPI::Element';
	behaves_like_augmented_ppi_class 'PPI::Statement';
	behaves_like_augmented_ppi_class 'PPI::Statement::Break';
	behaves_like_augmented_ppi_class 'PPI::Statement::Compound';
	behaves_like_augmented_ppi_class 'PPI::Statement::Data';
	behaves_like_augmented_ppi_class 'PPI::Statement::End';
	behaves_like_augmented_ppi_class 'PPI::Statement::Expression';
	behaves_like_augmented_ppi_class 'PPI::Statement::Given';
	behaves_like_augmented_ppi_class 'PPI::Statement::Include';
	behaves_like_augmented_ppi_class 'PPI::Statement::Null';
	behaves_like_augmented_ppi_class 'PPI::Statement::Package';
	behaves_like_augmented_ppi_class 'PPI::Statement::Scheduled';
	behaves_like_augmented_ppi_class 'PPI::Statement::Sub';
	behaves_like_augmented_ppi_class 'PPI::Statement::Variable';
	behaves_like_augmented_ppi_class 'PPI::Statement::When';
	behaves_like_augmented_ppi_class 'PPI::Structure';
	behaves_like_augmented_ppi_class 'PPI::Structure::Block';
	behaves_like_augmented_ppi_class 'PPI::Structure::Condition';
	behaves_like_augmented_ppi_class 'PPI::Structure::Constructor';
	behaves_like_augmented_ppi_class 'PPI::Structure::For';
	behaves_like_augmented_ppi_class 'PPI::Structure::Given';
	behaves_like_augmented_ppi_class 'PPI::Structure::List';
	behaves_like_augmented_ppi_class 'PPI::Structure::Subscript';
	behaves_like_augmented_ppi_class 'PPI::Structure::Unknown';
	behaves_like_augmented_ppi_class 'PPI::Structure::When';
	behaves_like_augmented_ppi_class 'PPI::Token';
	behaves_like_augmented_ppi_class 'PPI::Token::ArrayIndex';
	behaves_like_augmented_ppi_class 'PPI::Token::Attribute';
	behaves_like_augmented_ppi_class 'PPI::Token::BOM';
	behaves_like_augmented_ppi_class 'PPI::Token::Cast';
	behaves_like_augmented_ppi_class 'PPI::Token::Comment';
	behaves_like_augmented_ppi_class 'PPI::Token::Data';
	behaves_like_augmented_ppi_class 'PPI::Token::End';
	behaves_like_augmented_ppi_class 'PPI::Token::HereDoc';
	behaves_like_augmented_ppi_class 'PPI::Token::Label';
	behaves_like_augmented_ppi_class 'PPI::Token::Magic';
	behaves_like_augmented_ppi_class 'PPI::Token::Number::Binary';
	behaves_like_augmented_ppi_class 'PPI::Token::Number::Exp';
	behaves_like_augmented_ppi_class 'PPI::Token::Number::Float';
	behaves_like_augmented_ppi_class 'PPI::Token::Number::Hex';
	behaves_like_augmented_ppi_class 'PPI::Token::Number::Octal';
	behaves_like_augmented_ppi_class 'PPI::Token::Number::Version';
	behaves_like_augmented_ppi_class 'PPI::Token::Number';
	behaves_like_augmented_ppi_class 'PPI::Token::Operator';
	behaves_like_augmented_ppi_class 'PPI::Token::Pod';
	behaves_like_augmented_ppi_class 'PPI::Token::Prototype';
	behaves_like_augmented_ppi_class 'PPI::Token::Quote';
	behaves_like_augmented_ppi_class 'PPI::Token::Quote::Double';
	behaves_like_augmented_ppi_class 'PPI::Token::Quote::Interpolate';
	behaves_like_augmented_ppi_class 'PPI::Token::Quote::Literal';
	behaves_like_augmented_ppi_class 'PPI::Token::Quote::Single';
	behaves_like_augmented_ppi_class 'PPI::Token::QuoteLike';
	behaves_like_augmented_ppi_class 'PPI::Token::QuoteLike::Backtick';
	behaves_like_augmented_ppi_class 'PPI::Token::QuoteLike::Command';
	behaves_like_augmented_ppi_class 'PPI::Token::QuoteLike::Readline';
	behaves_like_augmented_ppi_class 'PPI::Token::QuoteLike::Regexp';
	behaves_like_augmented_ppi_class 'PPI::Token::QuoteLike::Words';
	behaves_like_augmented_ppi_class 'PPI::Token::Regexp';
	behaves_like_augmented_ppi_class 'PPI::Token::Regexp::Match';
	behaves_like_augmented_ppi_class 'PPI::Token::Regexp::Substitute';
	behaves_like_augmented_ppi_class 'PPI::Token::Regexp::Transliterate';
	behaves_like_augmented_ppi_class 'PPI::Token::Separator';
	behaves_like_augmented_ppi_class 'PPI::Token::Structure';
	behaves_like_augmented_ppi_class 'PPI::Token::Symbol';
	behaves_like_augmented_ppi_class 'PPI::Token::Unknown';
	behaves_like_augmented_ppi_class 'PPI::Token::Whitespace';
	behaves_like_augmented_ppi_class 'PPI::Token::Word';
};

subtest "PPIx augmented nodes" => sub {
	sub behaves_like_ppix_augment_class;
	plan tests => 9;

	behaves_like_ppix_augment_class 'PPIx::Augment::Context::Package';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Anonymous';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Anonymous::Arrayref';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Anonymous::Hashref';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Anonymous::Coderef';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Do::Block';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Literal';
	behaves_like_ppix_augment_class 'PPIx::Augment::Expression::Term::Variable';
};

had_no_warnings;

done_testing;

sub search_isa {
	my ($class) = @_;
	no strict 'refs';
	grep { ! m/::_/ } @{ "${class}::ISA" };
}

sub search_source_file {
	my ($class) = @_;

	my $key = $class =~ s/::/\//gr . '.pm';
	$INC{$key};
}

sub augmented_class {
	my ($class) = @_;
	$class =~ s/^PPI::/PPIx::Augment::/r;
}

sub indent {
	map "\t$_", @_
}

sub build_isa_tree {
	my ($class) = @_;
	indent map {("isa $_", build_isa_tree ($_))} search_isa ($class);
}

sub its_isa_tree_should_be_documented {
	my ($ppix_class) = @_;

	my $title = "should document its inheritance tree - $ppix_class";
	my $source_file = search_source_file $ppix_class;

	unless ($source_file) {
		fail $title;
		diag "source file no found";
		return;
	}

	my $inheritance;
	my @nodes = @{ Pod::Simple::SimpleTree->new->parse_file ($source_file)->root };
	while (@nodes) {
		my $node = shift @nodes;
		next unless Ref::Util::is_arrayref ($node);
		next unless $node->[0] eq 'head1';
		last if $node->[2] && $node->[2] eq 'INHERITANCE';
	}

	unless (@nodes) {
		fail $title;
		diag "POD section <head1 INHERITANCE> not found";
		return;
	}

	my $got = $nodes[0][2];
	my $expect = join "\n", indent ($ppix_class, build_isa_tree ($ppix_class));

	my ($pod_indent) = $got =~ m/^(\s+)/;

	$expect =~ s/\t/$pod_indent/g;

	it $title
		=> got    => $got
		=> expect => $expect
		;
}

sub behaves_like_augmented_ppi_class {
	my ($ppi_class) = @_;

	subtest "PPIx::Augment counterpart of $ppi_class" => sub {
		my $augment_class = augmented_class $ppi_class;

		plan tests => 4;

		ok "it is a PPI element - $ppi_class"
			=> got => scalar eval { $ppi_class->isa (PPI::Element::) }
			;

		ok "it is PPIx::Augment element - $augment_class"
			=> got => scalar eval { $augment_class->isa (PPI::Element::) }
			;

		it "augmented class ISA"
			=> got    => [ search_isa $augment_class ]
			=> expect => [ (map { augmented_class $_ } search_isa $ppi_class), $ppi_class ]
			or diag "check PPIx::Augment::Elements, it should load them all"
			;

		its_isa_tree_should_be_documented $augment_class;
	};
}

sub behaves_like_ppix_augment_class {
	my ($augment_class) = @_;

	subtest "PPIx::Augment class $augment_class" => sub {
		plan tests => 2;

		ok "it is PPIx::Augment element - $augment_class"
			=> got => scalar eval { $augment_class->isa (PPI::Element::) }
			;

		its_isa_tree_should_be_documented $augment_class;
	};
}

