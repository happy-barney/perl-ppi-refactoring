
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

sub expect_ppix_bool;

sub assume_classification {
	my ($title, %args) = @_;

	$args{caller} //= scalar caller;

	my $element        = $args{element};
	my $classification = build_tested_classification %args;
	my $expect         = build_expect %args;

	$expect = expect_ppix_bool $expect
		unless $expect->$Safe::Isa::_isa (Test::Deep::Cmp::)
		;

	subtest $title => sub {
		local $_ = $element;

		assume q (should use 'current element')
			=> got    { $classification->() }
			=> expect => $expect
			;

		local $_ = q (foo);
		assume q (should favour 'effective element')
			=> got    { $classification->($element) }
			=> expect => $expect
			;
	};
}

sub expect_ppix_bool {
	state $class = test_deep_cmp (
		descend => sub {
			my ($self, $got) = @_;
			my $expect = $self->_val;

			return ! ($got xor $expect)
				if $got || $expect;

			return ! (defined $got xor defined $expect)
				if (defined $got or defined $expect);

			return 1;
		},

		_render_value => sub {
			my ($self, $value) = @_;

			return q (ppix_include) if $value;
			return q (ppix_exclude_all) unless defined $value;
			return q (ppix_exclude);
		},
	);

	return $class->new (@_);
}

sub expect_ppix_exclude {
	expect_ppix_bool (0);
}

sub expect_ppix_exclude_all {
	expect_ppix_bool (undef);
}

sub expect_ppix_include {
	expect_ppix_bool (1);
}

1;
