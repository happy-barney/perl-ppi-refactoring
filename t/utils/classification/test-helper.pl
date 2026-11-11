
use v5.14;
use warnings;

use Test::Load::Helper;

sub assume_classification {
	my ($title, %args) = @_;

	$args{caller} //= scalar caller;

	my $element        = $args{element};
	my $expect         = $args{expect};
	my $classification = _assume_ppi_build_classification (%args)
		// die q (classification not specified)
		;

	$expect = $_->()
		for grep $_, $args{caller}->can ($expect)
		;

	$expect = expect_ppi_bool ($expect)
		unless $expect->$Safe::Isa::_isa (Test::Deep::Cmp::)
		;

	subtest $title => sub {
		local $_ = $element;
		assume q (should accept current element as default element)
			=> got    { $classification->() }
			=> expect => $expect
			;

		local $_ = q (foo);
		assume q (should favour first argument)
			=> got    { $classification->($element) }
			=> expect => $expect
			;
	};
}

sub expect_ppi_bool {
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

			return q (ppi_include) if $value;
			return q (ppi_exclude_all) unless defined $value;
			return q (ppi_exclude);
		},
	);

	return $class->new (@_);
}

sub expect_ppi_exclude {
	expect_ppi_bool (0);
}

sub expect_ppi_exclude_all {
	expect_ppi_bool (undef);
}

sub expect_ppi_include {
	expect_ppi_bool (1);
}

1;
