
use v5.14;
use warnings;

use require::relative q (../traversal/test-helper-traversal.pl);

my $CLASSIFICATION_SINGLETON = q (classification);

sub testing_classification (&) {
	proclaim $CLASSIFICATION_SINGLETON => shift->();
}

sub assert_classification {
	my ($title, %args) = @_;

	my $element = $args{element};
	my $with    = $args{with} // [];
	my $expect  = $args{expect};

	Test::YAFT::test_frame {
		die q (classification not specified, 'testing_classification { } first)
			unless try_deduce $CLASSIFICATION_SINGLETON
			;

		my $classification = deduce $CLASSIFICATION_SINGLETON;

		$expect = expect_ppi_bool $expect
			unless $expect->$_isa (Test::Deep::Cmp::)
			;

		subtest $title => sub {
			local $_ = $element;

			it q (should accept current element as default element)
				=> got    => do { $classification->(@$with) }
				=> expect => $expect
				;

			local $_ = q (foo);
			it q (should favour first argument)
				=> got    => $classification->($element, @$with)
				=> expect => $expect
				;

			it q (should favour direct argument (after prefix-conditions))
				=> got    => $classification->($with, $element)
				=> expect => $expect
				;

			if (eq_deeply ppi_true, $expect) {
				it q (should favour element passed as an argument reference)
					=> got    => do { $classification->(\ [ ref $element ]) }
					=> expect => expect_ppi_false
					;
			}
		};
	}
}

1;
