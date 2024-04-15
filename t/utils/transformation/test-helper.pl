
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

my $SINGLETON_TRANSFORMATION = q (arrange-ppixa-transformation);

sub assume_transformation {
	my ($title, %args) = @_;

	$args{caller} //= scalar caller;

	Test::YAFT::test_frame {
		my $document       = ppi_document ($args{document});
		my $where          = $args{where};
		my $expect         = $args{expect};
		my $arguments      = $args{arguments} // sub { @_ };

		my ($transformation, @args) = _build_argument_function (
			$args{caller},
			$args{transformation},
			$SINGLETON_TRANSFORMATION,
		);

		die q (assume_transformation(): 'transformation' required)
			unless $transformation
			;

		assume $title
			=> got    {
				if (my @found = ppix_search $document, $where) {
					local $_ = $found[0];
					$transformation->(@args, $arguments->(@found));
				}
				ref ($expect) ? $document : $document->content
			}
			=> expect => $expect
		;
	};
}

sub testing_transformation (&) {
	proclaim $SINGLETON_TRANSFORMATION => shift;
}

1;

