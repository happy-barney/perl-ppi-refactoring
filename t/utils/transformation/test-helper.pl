
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

		subtest $title => sub {
			my @returns;

			assume q (should apply transformation without any incident)
				=> got    {
					if (my @found = @{ $document->find ($where) || []}) {
						local $_ = $found[0];
						@returns = $transformation->(@args, $arguments->(@found));
					}
					1
				}
				=> expect => expect_true
				;

			ref ($expect)
				? assume_ppi q (should transform source)
					=> got    => $document
					=> expect => $expect
				: assume_ppi q (should transform source)
					=> got    => $document->content
					=> expect => $expect
				;

			if ($args{returns}) {
				assume q (should return)
					=> got    => \ @returns
					=> expect => $args{returns}
					;
			}
 		};

	};
}

sub testing_transformation (&) {
	proclaim $SINGLETON_TRANSFORMATION => shift;
}

1;

