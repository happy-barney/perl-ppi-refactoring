
use v5.14;
use warnings;

package PPIx::Augment::Statement::Extends {
	use parent qw[ PPI::Statement ];
	use PPI;

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Statement::Extends - Wrap known statements defininig OOP extends

=head1 INHERITANCE

	PPIx::Augment::Statement::Extends
		isa PPI::Statement
			isa PPI::Node
				isa PPI::Element

=head1 DESCRIPTION

Every L<PPI::Element> class has its augmented counterpart (used as marker interface).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
