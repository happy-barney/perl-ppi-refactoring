
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

use PPIx::Refactor;

my $SINGLETON_REFACTORING = q (arrange-ppixa-refactoring);

sub assume_refactoring {
	my ($title, %args) = @_;

	$args{caller} //= caller;

	Test::YAFT::test_frame {
		subtest $title => sub {
			my $document = _assume_ppi_build_got (%args);
			my $expect_document = $args{expect_document};
			my $expect_analyze  = $args{expect_analyze};
			my $expect_refactor = $args{expect_refactor};
			my $expect_result   = $args{expect_result};
			my $refactoring     = $args{refactoring}
				// deduce_undef ($SINGLETON_REFACTORING)
				// die q (assume_refactoring (): 'refactoring' is required)
				;

			assume_ppi q (PPI document structure before applying refactoring)
				=> got    => $document
				=> expect => $expect_document
				if defined $expect_document
				;

			my $refactor = PPIx::Refactor::->new ($refactoring);

			assume_ppi q (analyze () should return list of triggering elements)
				=> got    => [ $refactor->analyze ($document) ]
				=> expect => $expect_analyze
				if defined $expect_analyze
				;

			assume q (refactor () should return number of invokations)
				=> got    { $refactor->refactor ($document) }
				=> expect => $expect_refactor // expect_compare (q (>=), 0)
				;

			if (defined $expect_result) {
				$expect_result = $expect_result->content
					if $expect_result->$_DOES (PPI::Element::)
					;

				$document = $document->content
					unless ref $expect_result
					;

				my $code = ref ($expect_result) ? \ &assume_ppi : \ &assume;

				$code->(
					q (refactor () should transform document)
					=> got    => $document
					=> expect => $expect_result
				);
			}
		};
	};
}

sub testing_refactoring (&) {
	proclaim $SINGLETON_REFACTORING => shift->();
}

1;

