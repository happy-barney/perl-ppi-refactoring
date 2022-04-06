
use v5.14;
use warnings;

use require::relative "../../test-helper.pl";

sub expect_ppi_bool {
	state $class = test_deep_cmp (
		descend => sub {
			my ($self, $got) = @_;

			return ! ($got xor $self->{val})
				if $got || $self->{val};

			return ! (defined $got xor defined $self->{val})
				if (defined $got or defined $self->{val});

			return 1;
		},
		renderGot => sub {
			my ($self, $got) = @_;

			return "ppi_true" if $got;
			return "ppi_false_dont_descent" unless defined $got;
			return "ppi_false";
		},
		renderExp => sub {
			my ($self) = @_;

			return $self->renderGot ($self->{val});
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
