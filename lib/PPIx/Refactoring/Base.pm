
use v5.14;
use warnings;

package PPIx::Refactoring::Base {
	use Getopt::Long qw[];

	sub refactoring;

	sub _parse_options {
		my ($self, $options, %spec) = @_;

		my %params;
		Getopt::Long::GetOptionsFromArray (
			\ %params,
			$options,
			%spec,
		);

		return \%params;
	}

	1;
}
