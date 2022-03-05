
use v5.14;
use warnings;

package PPIx::Augment::Expression {
	use parent qw[ PPIx::Augment::Statement::Expression ];

	use HPB::PPIx::Utils (
		qw[ create_element ],
		qw[ replace_element ],
	);

	sub _accessor {
		my ($self, $key, $new) = @_;

		if (@_ > 2) {
			my $create = 1;
			if ($self->{$key}) {
				$create = 0;
				$self->{$key}->__insert_before ($new);
				$self->{$key}->remove;
			}

			$self->{$key} = $new;

			return ($new, $create);
		}

		$self->{$key};
	}

	sub _move_next_insignificant_siblings {
		my ($self, $from_element) = @_;

		while (my $sibling = $from_element->next_sibling) {
			last if $sibling->significant;
			$self->add_element ($sibling->clone);
			$sibling->remove;
		}
	}

	sub _move_next_sibling {
		my ($self, $from_element) = @_;

		my $sibling = $from_element->next_sibling;
		$self->add_element ($sibling->clone);
		$sibling->remove;
	}

	sub _find_first_child {
		my ($self, $class) = @_;

		my $rv = $self->find_first (sub { ($_[1]->isa ($class)) || undef });

		return unless $rv;
		return $rv;
	}

	sub _augment_build {
		my ($class, $first_child, @children) = @_;

		my $self = create_element $class => $first_child->clone;

		for my $child (@children) {
			$self->_move_next_insignificant_siblings ($first_child);
			$self->_move_next_sibling ($first_child);
		}

		replace_element $first_child, $self;

		return $self;
	}

	sub _augment_element {
		my ($class, $element) = @_;

		my $self = create_node $class => $element->clone;

		replace_element ($element, $self);

		return $self;
	}

	sub _augment_snext_sibling {
		my ($class, $augment_from) = @_;

		$class->_augment_element ($augment_from->snext_sibling);
	}

	sub _augment_sprevious_sibling {
		my ($class, $augment_from) = @_;

		$class->_augment_element ($augment_from->sprevious_sibling);
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
