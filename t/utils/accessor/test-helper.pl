
use v5.14;
use warnings;

use require::relative q (../test-helper.pl);

sub assume_accessor {
	my ($title, %args) = @_;

	$args{caller} //= scalar caller;

	my $accessor = _assume_ppi_build_accessor (%args)
		// die q (Accessor must be specified either via 'accessor' named parameter or via 'testing_accesor { }')
		;
	my $found    = _assume_ppi_build_found (%args);
	my $got      = [ map $accessor->($_), Ref::Util::is_plain_arrayref ($found) ? @$found : $found ];

	assume $title
		=> got    => $got
		=> expect => $args{expect}
		;
}

1;

