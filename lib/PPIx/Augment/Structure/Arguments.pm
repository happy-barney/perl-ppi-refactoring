
use v5.14;
use warnings;

package PPIx::Augment::Structure::Arguments {
	use parent qw[ PPIx::Augment::Structure ];

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Structure::Arguments - Augmented PPI::Structure

=head1 INHERITANCE

	PPIx::Augment::Structure::Arguments
		isa PPIx::Augment::Structure
			isa PPI::Augment::Node
				isa PPI::Augment::Element
			isa PPI::Structure
				isa PPI::Node
					isa PPI::Element

=head1 DESCRIPTION

Method or function call arguments.

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
