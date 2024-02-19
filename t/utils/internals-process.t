
use v5.14;
use warnings;

use require::relative '../test-helper.pl';

note <<'';
	PPI process / find related tests

sub expect_coderef;

subtest "_process_invoke() without arguments" => sub {
	my $code = PPIx::Augment::Utils::_process_invoke ();

	it "should return undef"
		=> got    => $code
		=> expect => undef
		;
};

subtest "_process_invoke() with single invoke argument" => sub {
	my @log = ();
	my $code = PPIx::Augment::Utils::_process_invoke (
		where  { push @log, "where" },
		invoke { push @log, "first" },
		where  { push @log, "where" },
	);

	it "should return function"
		=> got    => $code
		=> expect => expect_coderef
		;

	it "should evaluate as 1"
		=> got    => $code->()
		=> expect => 1
		;

	it "should call provided invoke block"
		=> got    => \ @log
		=> expect => [ "first" ]
		;
};

subtest "_process_invoke() with multiple invoke arguments" => sub {
	my @log = ();
	my $code = PPIx::Augment::Utils::_process_invoke (
		invoke { push @log, "first" },
		where  { push @log, "where" },
		invoke { push @log, "second" },
	);

	it "should return function"
		=> got    => $code
		=> expect => expect_coderef
		;

	it "should evaluate as 1"
		=> got    => $code->()
		=> expect => 1
		;

	it "should call only provided invoke blocks"
		=> got    => \ @log
		=> expect => [ "first", "second" ]
		;
};

subtest "_process_where() without arguments" => sub {
	my $code = PPIx::Augment::Utils::_process_where ();

	it "should return undef"
		=> got    => $code
		=> expect => undef
		;
};

subtest "_process_where() with single where argument" => sub {
	my @log = ();
	my $code = PPIx::Augment::Utils::_process_where (
		invoke { push @log, "invoke" },
		where  { push @log, "first"; ppi_true },
		invoke { push @log, "invoke" },
	);

	it "should return function"
		=> got    => $code
		=> expect => expect_coderef
		;

	it "should evaluate as true"
		=> got    => $code->()
		=> expect => ppi_true
		;

	it "should call provided where block"
		=> got    => \ @log
		=> expect => [ "first" ]
		;
};

subtest "_process_where() with multiple where arguments (all evaluated as true)" => sub {
	my @log = ();
	my $code = PPIx::Augment::Utils::_process_where (
		invoke { push @log, "invoke" },
		where  { push @log, "first"; ppi_true },
		invoke { push @log, "invoke" },
		where  { push @log, "second"; ppi_true },
		where  { push @log, "third"; ppi_true },
	);

	it "should return function"
		=> got    => $code
		=> expect => expect_coderef
		;

	it "should evaluate as true"
		=> got    => $code->()
		=> expect => ppi_true
		;

	it "should call provided where block"
		=> got    => \ @log
		=> expect => [ "first", "second", "third" ]
		;
};

subtest "_process_where() with multiple where arguments (evaluates as ppi_false)" => sub {
	my @log = ();
	my $code = PPIx::Augment::Utils::_process_where (
		invoke { push @log, "invoke" },
		where  { push @log, "first"; ppi_true },
		invoke { push @log, "invoke" },
		where  { push @log, "second"; ppi_false },
		where  { push @log, "third"; ppi_true },
	);

	it "should return function"
		=> got    => $code
		=> expect => expect_coderef
		;

	it "should evaluate as ppi_false"
		=> got    => $code->()
		=> expect => ppi_false
		;

	it "should call provided where block until false is reached"
		=> got    => \ @log
		=> expect => [ "first", "second" ]
		;
};

subtest "_process_where() with multiple where arguments (evaluates as ppi_false_dont_descent)" => sub {
	my @log = ();
	my $code = PPIx::Augment::Utils::_process_where (
		invoke { push @log, "invoke" },
		where  { push @log, "first"; ppi_true },
		invoke { push @log, "invoke" },
		where  { push @log, "second"; ppi_false_dont_descent },
		where  { push @log, "third"; ppi_true },
	);

	it "should return function"
		=> got    => $code
		=> expect => expect_coderef
		;

	it "should evaluate as undef"
		=> got    => $code->()
		=> expect => undef
		;

	it "should call provided where block until false is reached"
		=> got    => \ @log
		=> expect => [ "first", "second" ]
		;
};

had_no_warnings;

done_testing;

use Ref::Util qw[];

sub expect_coderef {
	state $class = test_deep_cmp (
		isa             => [ 'Test::Deep::Cmp' ],
		descend         => sub {
			my ($self, $got) = @_;
			return Ref::Util::is_coderef ($got);
		},
		diag_message    => sub {
			my ($self, $where) = @_;
			return "Checking whether $where is coderef";
		},
		renderGot       => sub {
			my ($self, $got) = @_;

			return ref $got;
		},
		renderExp       => sub {
			return "CODE";
		},
	);

	return $class->new ();
}

