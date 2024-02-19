
use v5.14;
use warnings;

use require::relative '../test-helper.pl';

it "ppix_process() without arguments should report no-element processed"
	=> got    => ppix_process ()
	=> expect => 0
	;

my @log;
my $document = document "1;foo;{2;bar;}";
it "ppix_process() should return number of processed elements"
	=> got    => ppix_process (
		$document
		=> where  { current->isa ('PPI::Node') }
		=> invoke { push @log, ref current }
		=> invoke { push @log, current->content }
	)
	=> expect => 6
	;

it "ppix_process() should invoke all invoke blocks"
	=> got    => \@log
	=> expect => [
		"PPI::Statement",
		"1;",
		"PPI::Statement",
		"foo;",
		"PPI::Statement::Compound",
		"{2;bar;}",
		"PPI::Structure::Block",
		"{2;bar;}",
		"PPI::Statement",
		"2;",
		"PPI::Statement",
		"bar;",
	];

had_no_warnings;

done_testing;

