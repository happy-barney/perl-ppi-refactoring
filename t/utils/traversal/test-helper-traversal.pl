
use v5.14;
use warnings;

use require::relative q (../../test-helper.pl);

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

			return q (ppi_true) if $value;
			return q (ppi_false_dont_descent) unless defined $value;
			return q (ppi_false);
		},
	);

	return $class->new (@_);
}

sub expect_ppi_false {
	expect_ppi_bool (0);
}

sub expect_ppi_false_do_not_descend {
	expect_ppi_bool (undef);
}

sub expect_ppi_true {
	expect_ppi_bool (1);
}

1;
