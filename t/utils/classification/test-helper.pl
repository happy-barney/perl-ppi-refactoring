
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

sub expect_ppi_bool {
	state $class = test_deep_cmp (
		descend => sub {
			my ($self, $got) = @_;
			my $expect = $self->_val;

			return ! ($got xor $expect)
				if $got || $expect
				;

			return ! (defined $got xor defined $expect);
		},
		_render_value => sub {
			my ($self, $value) = @_;

			return q (ppi_include)     if $value ;
			return q (ppi_exclude)     if defined $value;
			return q (ppi_exclude_all);
		},
	);

	return $class->new (@_);
}

sub expect_ppi_exclude () {
	expect_ppi_bool (0);
}

sub expect_ppi_exclude_all () {
	expect_ppi_bool (undef);
}

sub expect_ppi_include () {
	expect_ppi_bool (1);
}

1;
