
use v5.14;
use warnings;

package PPIx::Augment::Expression {
	use parent qw[ PPIx::Augment::Statement::Expression ];

	sub _accessor {
		my ($self, $key, $new) = @_;

		if (@_ > 2) {
			if ($self->{$key}) {
				$self->{$key}->__insert_before ($new);
				$self->{$key}->remove;
			}

			$self->{$key} = $new
		}

		$self->{$key};
	}

	1;
};

__END__

=pod

=encoding utf-8

=head1 NAME

PPIx::Augment::Expression - Base class for expressions

=head1 INHERITANCE

	PPIx::Augment::Expression
		isa PPIx::Augment::Statement::Expression
			isa PPIx::Augment::Statement
				isa PPIx::Augment::Node
					isa PPIx::Augment::Element
						isa PPI::Element
					isa PPI::Node
						isa PPI::Element
				isa PPI::Statement
					isa PPI::Node
						isa PPI::Element
			isa PPI::Statement::Expression
				isa PPI::Statement
					isa PPI::Node
						isa PPI::Element

=head1 DESCRIPTION

Expression is has a value and, unlike statement, can be used wherever value is required.
Though in perl every expression can be used as a statement
(hence inheritance via L<PPI::Statement::Expression>).

=head1 AUTHOR

Branislav Zahradník <barney@cpan.org>

=head1 COPYRIGHT AND LICENCE

This module is part of L<PPIx::Augment> distribution.

=cut
