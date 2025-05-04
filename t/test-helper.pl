
use v5.14;
use warnings;

use Carp::Always; # must be before Test::YAFT - replaces $SIG{__WARN__}

use Context::Singleton;
use Path::Tiny qw (path);
use PPI v1.277;
use PPI::Dumper;
use Ref::Util  qw (is_plain_arrayref);
use Safe::Isa  qw ();
use Scalar::Util;
use Test::YAFT qw (:all), it => { -as => q (assume) };

use PPIx::Augment;
use PPIx::Augment::Utils;

### ############################################################

my $SINGLETON_CLASSIFICATION = q (arrange-testing-classification);
my $SINGLETON_DOCUMENT       = q (arrange-ppixa-document);

### ############################################################

sub _build_argument_function;
sub deduce_undef;
sub distribution_root;
sub fixture_path;
sub fixture_root;
sub ppi_document;
sub ppi_dump;
sub tests_root;

### ############################################################

sub _build_argument_caller_value {
	my ($caller, $what) = @_;

	$what = $_->()
		for grep { $_ } $caller->$Safe::Isa::_can ($what)
		;

	return $what;
}

sub _build_argument_function {
	my ($caller, $function, $singleton, @custom_args) = @_;

	$function
		//= deduce_undef ($singleton)
		// return
		;

	my @args;

	($function, @args) = @$function
		if is_plain_arrayref ($function)
		;

	$function = _build_argument_caller_value ($caller, $function);

	return sub { $function-> (@_, @args, @custom_args) };
}

sub build_expect (\%) {
	my ($args) = @_;

	return _build_argument_caller_value ($args->{caller}, $args->{expect});
}

sub build_tested_classification (\%) {
	my ($args) = @_;

	return _build_argument_function (
		$args->{caller} // caller,
		$args->{classification},
		$SINGLETON_CLASSIFICATION,
		@{ $args->{conditions} // $args->{with} // [] }
	)
		// die q (Argument 'classification' must be specified)
		;
}
sub _assume_ppi_build_found {
	my (%args) = @_;

	my $found = my $got = _assume_ppi_build_got (%args)
		// return
		;

	if (my $where = _assume_ppi_build_where (%args)) {
		$found = $got->find ($where) || [];

		for my $invoke (grep $_, $args{invoke}) {
			for my $element (@$found) {
				$invoke->($got, $element);
			}
		}
	}

	return $found;
}

sub _assume_ppi_build_got {
	my (%args) = @_;

	return $args{got}     if exists $args{got};
	return $args{element} if exists $args{element};

	my $got = $args{document}
		// deduce_undef ($SINGLETON_DOCUMENT)
		// return
		;

	state $document; # preserve it as long as possible
	$document = $got = ppi_document ($got)
		unless $got->$Safe::Isa::_isa (PPI::Element::)
		;

	return $got;
}

sub _assume_ppi_build_where {
	my (%args) = @_;

	if (my $where_first = $args{first}) {
		return sub { state $i = 0; $where_first->(@_) && ($i++ > 0 ? undef : 1) };
	}

	return $args{where};
}

sub _build_argument_function {
	my ($caller, $value, $singleton) = @_;

	my $function //= deduce_undef ($singleton) // return;

	my @args;
	($function, @args) = @$function
		if Ref::Util::is_plain_arrayref ($function)
		;

	$function = $_
		for grep $_, $caller->can ($function)
		;

	return ($function, @args);
}

sub arrange_document (&) {
	proclaim $SINGLETON_DOCUMENT => shift->();
}

sub assume_ppi {
	my ($title, %args) = @_;

	$args{caller} //= scalar caller;

	Test::YAFT::test_frame {
		my $got   = _assume_ppi_build_got (%args);
		my $found = _assume_ppi_build_found (got => $got, %args);

		assume ($title
			=> got    => $found
			=> expect => $args{expect}
			=> diag   => \& Test::Deep::deep_diag
		) or do {
			diag (q (Got PPI document:));
			ppi_dump $got;
			diag (q (Found PPI nodes:));
			ppi_dump $found;
		};
	};
}

sub deduce_undef {
	my ($singleton) = @_;

	return undef
		unless defined $singleton
		;

	return undef
		unless try_deduce $singleton
		;

	return deduce $singleton;
}

sub distribution_root {
	return tests_root->parent;
}

sub expect (&) {
	expect => shift->()
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

sub expect_no_element () {
	return q ();
}

sub expect_nodeset {
	return [ @_ ];
}

sub fixture {
	return fixture_path (@_)->slurp_utf8;
}

sub fixture_list {
	my $root = fixture_root;

	return map { $_->relative ($root) } $root->children;
}

sub fixture_path {
	return fixture_root ()->child (@_);
}

sub fixture_root {
	return tests_root->child (q (fixture));
}

sub ppi_document {
	my ($source) = @_;

	return
		unless defined $source
		;

	return $source
		if ref $source && $source->isa (PPI::Document::)
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

sub testing_classification (&) {
	proclaim $SINGLETON_TESTING_CLASSIFICATION => shift;
}

sub tests_root {
	return path (__FILE__)->parent;
}

1;

