
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

my $SINGLETON_BUILDER = q (arrange-ppixa-builder);

sub assume_builder {
	my ($title, %args) = @_;

	$args{caller} //= scalar caller;

	Test::YAFT::test_frame {
		my ($builder, @args) = _build_argument_function (
			$args{caller},
			$args{builder},
			$SINGLETON_BUILDER
		);

		die q (assume_builder (): 'builder' is required)
			unless $builder
			;

		assume $title
			=> got    { $builder->(@args, @{ $args{content} // [] }) }
			=> expect => $args{expect}
			;
	};
}

sub testing_builder (&) {
	proclaim $SINGLETON_BUILDER => shift;
}

1;
