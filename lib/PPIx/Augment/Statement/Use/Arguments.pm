
use v5.14;
use warnings;

package PPIx::Augment::Statement::Use::Arguments {
	use parent q (PPI::Node);

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Statement::Use::Arguments - Wraps arguments of use statement

=head1 INHERITANCE

	PPIx::Augment::Statement::Use
		isa PPI::Statement::Include
			isa PPI::Statement
			isa PPI::Node
				isa PPI::Element

=head1 DESCRIPTION

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
